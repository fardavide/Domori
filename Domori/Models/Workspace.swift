import FirebaseFirestore

struct Workspace: Codable {
  @DocumentID var id: String?
  var userIds: [String]
}
