import FirebaseFirestore

struct Workspace: Codable {
  @DocumentID var id: String?
  var userIds: [String]
}

struct WorkspaceJoinRequest: Codable {
  @DocumentID var id: String?
  var workspaceId: String
  var userId: String
}
