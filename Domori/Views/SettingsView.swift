import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var userManager = UserManager.shared
    
    @Query private var workspaces: [SharedWorkspace]
    @Query private var invitations: [WorkspaceInvitation]
    
    @State private var selectedWorkspace: SharedWorkspace?
    @State private var showingInviteUser = false
    
    var body: some View {
        NavigationView {
            Form {
                // User Information
                if let currentUser = userManager.currentUser {
                    Section("Account") {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
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
                        
                        Button(action: {
                            showingInviteUser = true
                        }) {
                            Label("Invite People to Collaborate", systemImage: "person.badge.plus")
                                .foregroundColor(.blue)
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
                
                Section("App Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.1")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("4")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Data & Collaboration") {
                    NavigationLink(destination: ExportImportView()) {
                        Label("Export & Import Properties", systemImage: "square.and.arrow.up.on.square")
                    }
                    
                    HStack {
                        Text("Properties")
                        Spacer()
                        Text("Stored in iCloud")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Collaboration")
                        Spacer()
                        Text("Email-based invitations")
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Your property data is automatically synced across all your devices using iCloud. Collaborative workspaces allow you to share properties with others using email invitations.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("About") {
                    Text("Domori helps you manage and compare property listings with notes, photos, and ratings. Collaborate with others by creating shared workspaces and inviting team members via email.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
#if os(iOS)
            .navigationBarTitleDisplayMode(.large)
#endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedWorkspace) { workspace in
                WorkspaceDetailView(workspace: workspace)
            }
            .sheet(isPresented: $showingInviteUser) {
                if let primaryWorkspace = userPrimaryWorkspace {
                    InviteUserView(workspace: primaryWorkspace)
                }
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

// MARK: - Supporting Views

struct WorkspaceRowView: View {
    let workspace: SharedWorkspace
    var showOwner: Bool = false
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(workspace.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if showOwner {
                        Text("Owner: \(workspace.ownerEmail)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("\(workspace.properties?.count ?? 0) properties • \(workspace.allParticipants.count) members")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InvitationRowView: View {
    let invitation: WorkspaceInvitation
    let onResponse: (Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    if let workspace = invitation.workspace {
                        Text("Invitation to \"\(workspace.name)\"")
                            .font(.headline)
                    }
                    
                    if let inviter = invitation.inviter {
                        Text("From \(inviter.name) (\(inviter.email))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            if !invitation.message.isEmpty {
                Text(invitation.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.leading, 24)
            }
            
            HStack {
                Button("Accept") {
                    onResponse(true)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Button("Decline") {
                    onResponse(false)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                
                Spacer()
                
                Text("Expires \(invitation.expiryDate, format: .dateTime.day().month().year())")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 24)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [User.self, SharedWorkspace.self, WorkspaceInvitation.self], inMemory: true)
} 