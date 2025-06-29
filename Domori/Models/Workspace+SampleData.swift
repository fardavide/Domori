extension Workspace {
  static func sample(forUserId userId: String) -> Workspace {
    .init(userIds: [userId])
  }
}
