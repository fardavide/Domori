import SwiftUI
import SwiftData

struct CreateWorkspaceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var userManager = UserManager.shared
    
    @State private var workspaceName: String = ""
    @State private var inviteEmails: String = ""
    @State private var welcomeMessage: String = ""
    
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Workspace Details") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Workspace Name")
                            .font(.headline)
                        TextField("Enter workspace name", text: $workspaceName)
                            .textFieldStyle(.roundedBorder)
                        Text("Choose a name that describes your property collaboration")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Invite Others (Optional)") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Addresses")
                            .font(.headline)
                        TextField("Enter email addresses separated by commas", text: $inviteEmails, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                        Text("You can invite people now or later from the workspace settings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome Message")
                            .font(.headline)
                        TextField("Optional message to include with invitations", text: $welcomeMessage, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(2...4)
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Collaborative Features", systemImage: "person.2.fill")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureRow(icon: "square.and.arrow.up", text: "Share property listings with your team")
                            FeatureRow(icon: "pencil.and.outline", text: "Collaborate on property notes and ratings")
                            FeatureRow(icon: "icloud", text: "Automatic sync across all devices")
                            FeatureRow(icon: "person.crop.circle.badge.plus", text: "Invite and manage team members")
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Create Workspace")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createWorkspace()
                    }
                    .disabled(workspaceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.semibold)
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createWorkspace()
                    }
                    .disabled(workspaceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.semibold)
                }
                #endif
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func createWorkspace() {
        guard let currentUser = userManager.getCurrentUser(context: modelContext) else {
            errorMessage = "Unable to identify current user"
            showingError = true
            return
        }
        
        let trimmedName = workspaceName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter a workspace name"
            showingError = true
            return
        }
        
        // Create workspace
        let workspace = SharedWorkspace(name: trimmedName, owner: currentUser)
        modelContext.insert(workspace)
        
        // Process invitations if any
        let emails = parseEmails(from: inviteEmails)
        for email in emails {
            let invitation = WorkspaceInvitation(
                inviteeEmail: email,
                workspace: workspace,
                inviter: currentUser,
                message: welcomeMessage
            )
            modelContext.insert(invitation)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to create workspace: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func parseEmails(from text: String) -> [String] {
        let emails = text.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty && $0.contains("@") && $0.contains(".") }
        
        return Array(Set(emails)) // Remove duplicates
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    CreateWorkspaceView()
        .modelContainer(for: [User.self, SharedWorkspace.self, WorkspaceInvitation.self], inMemory: true)
} 