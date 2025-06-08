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
    @Relationship(deleteRule: .cascade) var ownedWorkspaces: [SharedWorkspace]?
    @Relationship var memberWorkspaces: [SharedWorkspace]?
    @Relationship(deleteRule: .cascade) var sentInvitations: [WorkspaceInvitation]?
    @Relationship var receivedInvitations: [WorkspaceInvitation]?
    
    init(name: String, email: String) {
        self.name = name
        self.email = email
        self.createdDate = Date()
        self.updatedDate = Date()
        self.ownedWorkspaces = []
        self.memberWorkspaces = []
        self.sentInvitations = []
        self.receivedInvitations = []
    }
    
    // Create personal workspace for user (call after user is inserted in context)
    func createPersonalWorkspace(context: ModelContext) {
        // Check if user already has a personal workspace
        let hasPersonalWorkspace = ownedWorkspaces?.contains { workspace in
            workspace.name == "\(self.name)'s Properties"
        } ?? false
        
        if !hasPersonalWorkspace {
            let personalWorkspace = SharedWorkspace(name: "\(self.name)'s Properties", owner: self)
            if ownedWorkspaces == nil {
                ownedWorkspaces = []
            }
            ownedWorkspaces!.append(personalWorkspace)
            context.insert(personalWorkspace)
        }
    }
    
    // Get user's primary workspace (for property storage)
    var primaryWorkspace: SharedWorkspace? {
        return ownedWorkspaces?.first { $0.isActive }
    }
    
    // Helper method to get workspaces where user is a member
    func getMemberWorkspaces() -> [SharedWorkspace] {
        return memberWorkspaces?.filter { $0.isActive } ?? []
    }
    
    // Helper method to get all workspaces (owned + member)
    func getAllWorkspaces(context: ModelContext) -> [SharedWorkspace] {
        var workspaces: [SharedWorkspace] = []
        if let owned = ownedWorkspaces {
            workspaces.append(contentsOf: owned.filter { $0.isActive })
        }
        if let member = memberWorkspaces {
            workspaces.append(contentsOf: member.filter { $0.isActive })
        }
        return workspaces
    }
} 