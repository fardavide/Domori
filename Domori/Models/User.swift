import Foundation
import SwiftData

@Model
final class User {
  var id: String = UUID().uuidString
  var name: String = ""
  var email: String = ""
  var createdDate: Date = Date()
  var updatedDate: Date = Date()
  
  // Relationships
  @Relationship(deleteRule: .cascade) var ownedWorkspace: SharedWorkspace?
  @Relationship var memberWorkspaces: [SharedWorkspace]?
  @Relationship(deleteRule: .cascade) var sentInvitations: [WorkspaceInvitation]?
  @Relationship var receivedInvitations: [WorkspaceInvitation]?
  
  init(name: String, email: String) {
    self.name = name
    self.email = email
    self.createdDate = Date()
    self.updatedDate = Date()
    self.ownedWorkspace = nil
    self.memberWorkspaces = []
    self.sentInvitations = []
    self.receivedInvitations = []
  }
  
  // Create personal workspace for user (call after user is inserted in context)
  func createPersonalWorkspace(context: ModelContext) -> SharedWorkspace {
    if let ownedWorkspace = ownedWorkspace {
      return ownedWorkspace
    } else {
      let personalWorkspace = SharedWorkspace(owner: self)
      ownedWorkspace = personalWorkspace
      context.insert(personalWorkspace)
      return personalWorkspace
    }
  }
  
  // Get user's primary workspace (for property storage)
  var primaryWorkspace: SharedWorkspace? {
    return ownedWorkspace
  }
  
  // Helper method to get workspaces where user is a member
  func getMemberWorkspaces() -> [SharedWorkspace] {
    return memberWorkspaces ?? []
  }
  
  // Helper method to get all workspaces (owned + member)
  func getAllWorkspaces(context: ModelContext) -> [SharedWorkspace] {
    var workspaces: [SharedWorkspace] = []
    if let owned = ownedWorkspace {
      workspaces.append(owned)
    }
    for workspace in memberWorkspaces ?? [] {
      workspaces.append(workspace)
    }
    return workspaces
  }
}
