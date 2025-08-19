// 1) Keep this returning UUID (you already do)
private func currentUserId() async throws -> UUID {
    let user = try await client.auth.user()
    return user.id
}

// 2) Use UUID in filters (NOT uid.uuidString)
func load() async {
    // ...
    let uid = try await currentUserId()
    let resp: PostgrestResponse<[Child]> = try await client.database
        .from("children")
        .select()
        .eq("parent_user_id", value: uid)   // <-- UUID
        .order("created_at", ascending: true)
        .execute()
    self.children = resp.value
    // ...
}

// 3) Insert payload uses UUID for parent_user_id
struct NewChild: Encodable {
    let id: UUID
    let parent_user_id: UUID   // <-- UUID type
    let name: String
    let birthdate: String?
    let avatar_url: String?
}

func add(name: String, birthdate: Date?, avatarData: Data? = nil) async {
    // ...
    let uid = try await currentUserId()
    let id = UUID()
    var avatarPath: String? = nil
    // (upload unchanged)
    let payload = NewChild(
        id: id,
        parent_user_id: uid,                 // <-- UUID
        name: name,
        birthdate: birthdate.map { Child.dateOnly.string(from: $0) },
        avatar_url: avatarPath
    )
    let _: PostgrestResponse<[Child]> = try await client.database
        .from("children")
        .insert(payload)
        .select()
        .execute()
    await load()
}
