import SwiftUI
import SwiftData

struct CollaborationView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var userManager = UserManager.shared
    
    @Query private var workspaces: [SharedWorkspace]
    @Query private var invitations: [WorkspaceInvitation]
    
    @State private var selectedWorkspace: SharedWorkspace?
    
    var body: some View {
        NavigationView {
            List {
                // Current User Info
                if let currentUser = userManager.currentUser {
                    Section {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(currentUser.name)
                                    .font(.headline)
                                Text(currentUser.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Pending Invitations
                if !pendingInvitations.isEmpty {
                    Section("Pending Invitations") {
                        ForEach(pendingInvitations, id: \.id) { invitation in
                            InvitationRowView(invitation: invitation) {
                                handleInvitationResponse(invitation, accepted: $0, context: modelContext)
                            }
                        }
                    }
                }
                
                // My Properties Workspace
                Section("My Properties") {
                    if let primaryWorkspace = userPrimaryWorkspace {
                        WorkspaceRowView(workspace: primaryWorkspace) {
                            selectedWorkspace = primaryWorkspace
                        }
                    } else {
                        Text("No primary workspace found")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                // Shared With Me
                if !sharedWorkspaces.isEmpty {
                    Section("Shared With Me") {
                        ForEach(sharedWorkspaces, id: \.id) { workspace in
                            WorkspaceRowView(workspace: workspace, showOwner: true) {
                                selectedWorkspace = workspace
                            }
                        }
                    }
                }
            }
            .navigationTitle("Collaboration")
            .sheet(item: $selectedWorkspace) { workspace in
                WorkspaceDetailView(workspace: workspace)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var pendingInvitations: [WorkspaceInvitation] {
        guard let currentUser = userManager.currentUser else { return [] }
        return invitations.filter { invitation in
            invitation.inviteeEmail == currentUser.email && invitation.isActive
        }
    }
    
    private var userPrimaryWorkspace: SharedWorkspace? {
        guard let currentUser = userManager.getCurrentUser(context: modelContext) else { return nil }
        return currentUser.primaryWorkspace
    }
    
    private var sharedWorkspaces: [SharedWorkspace] {
        guard let currentUser = userManager.currentUser else { return [] }
        return workspaces.filter { workspace in
            workspace.ownerEmail != currentUser.email && 
            workspace.members?.contains { $0.email == currentUser.email } == true &&
            workspace.isActive
        }
    }
    
    // MARK: - Actions
    
    // Removed deleteWorkspaces - users can't delete their primary workspace
    
    private func handleInvitationResponse(_ invitation: WorkspaceInvitation, accepted: Bool, context: ModelContext) {
        guard let currentUser = userManager.getCurrentUser(context: context),
              let workspace = invitation.workspace else { return }
        
        if accepted {
            invitation.accept()
            workspace.addMember(currentUser)
        } else {
            invitation.decline()
        }
        
        do {
            try context.save()
        } catch {
            print("Error handling invitation response: \(error)")
        }
    }
}



#Preview {
    CollaborationView()
        .modelContainer(for: [User.self, SharedWorkspace.self, WorkspaceInvitation.self], inMemory: true)
} 