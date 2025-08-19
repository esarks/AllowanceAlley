import Foundation
import Supabase

@MainActor
final class ChoreService: ObservableObject {
    @Published var chores: [Chore] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseManager.shared.client

    // MARK: - Helpers

    private func currentUserId() async throws -> UUID {
        try await client.auth.user().id
    }

    // MARK: - READ

    func load() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let uid = try await currentUserId()
            let resp: PostgrestResponse<[Chore]> = try await client.database
                .from("chores")
                .select()
                // IMPORTANT: eq expects strings for UUIDs; send uuidString
                .eq("parent_user_id", value: uid.uuidString)
                .order("created_at", ascending: true)
                .execute()

            self.chores = resp.value
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: - CREATE

    func add(
        title: String,
        notes: String? = nil,
        dueDate: Date? = nil,
        points: Int,
        childId: UUID? = nil
    ) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        struct NewChore: Encodable {
            let id: UUID
            let parent_user_id: String
            let child_id: String?
            let title: String
            let notes: String?
            let due_date: String?
            let points: Int
            let is_completed: Bool
        }

        do {
            let uid = try await currentUserId()
            let id = UUID()

            let payload = NewChore(
                id: id,
                parent_user_id: uid.uuidString,
                child_id: childId?.uuidString,
                title: title,
                notes: notes,
                due_date: dueDate.map { Chore.dateOnly.string(from: $0) },
                points: points,
                is_completed: false
            )

            let _: PostgrestResponse<[Chore]> = try await client.database
                .from("chores")
                .insert(payload)
                .select()
                .execute()

            await load()
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: - UPDATE

    func update(_ chore: Chore) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        struct UpdateChore: Encodable {
            let child_id: String?
            let title: String
            let notes: String?
            let due_date: String?
            let points: Int
            let is_completed: Bool
        }

        do {
            let payload = UpdateChore(
                child_id: chore.child_id?.uuidString,
                title: chore.title,
                notes: chore.notes,
                due_date: chore.due_date,
                points: chore.points,
                is_completed: chore.is_completed
            )

            let _: PostgrestResponse<[Chore]> = try await client.database
                .from("chores")
                .update(payload)
                .eq("id", value: chore.id.uuidString)
                .select()
                .execute()

            await load()
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: - DELETE

    func delete(id: UUID) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let _: PostgrestResponse<Void> = try await client.database
                .from("chores")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()

            await load()
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    // MARK: - TOGGLE COMPLETE

    func setCompleted(id: UUID, _ isCompleted: Bool) async {
        errorMessage = nil
        do {
            let _: PostgrestResponse<[Chore]> = try await client.database
                .from("chores")
                .update(["is_completed": isCompleted])
                .eq("id", value: id.uuidString)
                .select()
                .execute()
            await load()
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }
}
