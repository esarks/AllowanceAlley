private func currentUserId() async throws -> UUID {
    try await client.auth.user().id
}

// READ
func load() async {
    // ...
    let uid = try await currentUserId()
    let resp: PostgrestResponse<[Chore]> = try await client.database
        .from("chores")
        .select()
        .eq("parent_user_id", value: uid)    // <-- UUID
        .order("created_at", ascending: true)
        .execute()
    self.chores = resp.value
    // ...
}

// CREATE
struct NewChore: Encodable {
    let id: UUID
    let parent_user_id: UUID                 // <-- UUID
    let child_id: UUID?
    let title: String
    let notes: String?
    let due_date: String?
    let points: Int
    let is_completed: Bool
}

func add(title: String, notes: String?, dueDate: Date?, points: Int, childId: UUID?) async {
    // ...
    let uid = try await currentUserId()
    let id = UUID()
    let payload = NewChore(
        id: id,
        parent_user_id: uid,                 // <-- UUID
        child_id: childId,
        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
        notes: notes?.trimmingCharacters(in: .whitespacesAndNewlines),
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
}
