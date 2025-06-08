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
    func createPersonalWorkspace(context: ModelContext) {
        // Only create if user doesn't already have a workspace
        if ownedWorkspace == nil {
            let personalWorkspace = SharedWorkspace(name: "\(self.name)'s Properties", owner: self)
            ownedWorkspace = personalWorkspace
            context.insert(personalWorkspace)
        }
    }
    
    // Get user's primary workspace (for property storage)
    var primaryWorkspace: SharedWorkspace? {
        return ownedWorkspace?.isActive == true ? ownedWorkspace : nil
    }
    
    // Helper method to get workspaces where user is a member
    func getMemberWorkspaces() -> [SharedWorkspace] {
        return memberWorkspaces?.filter { $0.isActive } ?? []
    }
    
    // Helper method to get all workspaces (owned + member)
    func getAllWorkspaces(context: ModelContext) -> [SharedWorkspace] {
        var workspaces: [SharedWorkspace] = []
        if let owned = ownedWorkspace, owned.isActive {
            workspaces.append(owned)
        }
        if let member = memberWorkspaces {
            workspaces.append(contentsOf: member.filter { $0.isActive })
        }
        return workspaces
    }
} 