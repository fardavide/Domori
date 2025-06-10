import Foundation
import SwiftData

@Model
final class SharedWorkspace {
  var id: String = UUID().uuidString
  var createdDate: Date = Date()
  var updatedDate: Date = Date()
  
  // CloudKit sharing properties
  var shareRecordID: String? // CloudKit share record ID
  var shareURL: String? // CloudKit share URL for invitations
  var isShared: Bool = false // Whether this workspace is currently shared
  
  // Relationships - ALL users in this workspace see ALL properties
  @Relationship(inverse: \User.ownedWorkspace) var owner: User?
  @Relationship(inverse: \User.memberWorkspaces) var members: [User]?
  @Relationship(deleteRule: .cascade) var properties: [PropertyListing]? // All properties belong to workspace
  @Relationship(deleteRule: .cascade, inverse: \WorkspaceInvitation.workspace) var invitations: [WorkspaceInvitation]?
  
  init(owner: User) {
    self.owner = owner
    self.createdDate = Date()
    self.updatedDate = Date()
    self.members = []
    self.properties = []
    self.invitations = []
  }
  
  // Helper methods
  func addMember(_ user: User) {
    if members == nil {
      members = []
    }
    if !members!.contains(where: { $0.id == user.id }) {
      members!.append(user)
      updatedDate = Date()
    }
  }
  
  func removeMember(_ user: User) {
    members?.removeAll { $0.id == user.id }
    updatedDate = Date()
  }
  
  func isUserMember(_ user: User) -> Bool {
    guard let members = members else { return false }
    return members.contains { $0.id == user.id }
  }
  
  func isUserOwner(_ user: User) -> Bool {
    return owner?.id == user.id
  }
  
  // Get all participants (owner + members)
  var allParticipants: [User] {
    var participants: [User] = []
    if let owner = owner {
      participants.append(owner)
    }
    if let members = members {
      participants.append(contentsOf: members)
    }
    return participants
  }
  
  func addProperty(_ property: PropertyListing, context: ModelContext) {
    if properties == nil {
      properties = []
    }
    properties!.append(property)
    context.insert(property)
  }
}
