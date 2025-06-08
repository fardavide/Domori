import SwiftUI
import SwiftData
import CloudKit

struct InviteUserView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var userManager = UserManager.shared
    @State private var cloudKitManager = CloudKitSharingManager.shared
    
    let workspace: SharedWorkspace
    
    @State private var inviteeEmail: String = ""
    @State private var message: String = ""
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Invite Member") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address")
                            .font(.headline)
                        TextField("Enter email address", text: $inviteeEmail)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        
                        if !inviteeEmail.isEmpty && !isValidEmail(inviteeEmail) {
                            Text("Please enter a valid email address")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Personal Message (Optional)")
                            .font(.headline)
                        TextField("Add a personal message...", text: $message, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                        
                        Text("Let them know why you're inviting them to collaborate")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Invitation Preview") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.blue)
                            Text("Invitation Preview")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Subject: Collaboration Invitation for \"\(workspace.name)\"")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                if let currentUser = userManager.currentUser {
                                    Text("Hi there,")
                                    Text("\(currentUser.name) (\(currentUser.email)) has invited you to collaborate on the workspace \"\(workspace.name)\" in Domori.")
                                    
                                    if !message.isEmpty {
                                        Text("")
                                        Text("Personal message:")
                                        Text("\"\(message)\"")
                                            .italic()
                                            .padding(.leading, 8)
                                    }
                                    
                                    Text("")
                                    Text("To accept this invitation, sign in to Domori with this email address and check your collaboration tab.")
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                Section("Collaboration Benefits") {
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureRow(icon: "square.and.arrow.up", text: "Share property listings and data")
                        FeatureRow(icon: "pencil.and.outline", text: "Collaborate on notes and ratings")
                        FeatureRow(icon: "arrow.triangle.2.circlepath", text: "Real-time sync across devices")
                        FeatureRow(icon: "eye", text: "View and compare properties together")
                    }
                }
            }
            .navigationTitle("Invite Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send Invitation") {
                        sendInvitation()
                    }
                    .disabled(!canSendInvitation || isLoading)
                    .fontWeight(.semibold)
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var canSendInvitation: Bool {
        return isValidEmail(inviteeEmail) && !isEmailAlreadyInvited && !isEmailAlreadyMember
    }
    
    private var isEmailAlreadyInvited: Bool {
        let pendingInvitations = workspace.invitations?.filter { $0.isActive } ?? []
        return pendingInvitations.contains { $0.inviteeEmail == inviteeEmail.lowercased() }
    }
    
    private var isEmailAlreadyMember: Bool {
        return workspace.allParticipants.contains { $0.email == inviteeEmail.lowercased() }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.contains("@") && trimmed.contains(".")
    }
    
    private func sendInvitation() {
        guard let currentUser = userManager.getCurrentUser(context: modelContext) else {
            errorMessage = "Unable to identify current user"
            showingError = true
            return
        }
        
        let trimmedEmail = inviteeEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard canSendInvitation else {
            if isEmailAlreadyInvited {
                errorMessage = "This email address already has a pending invitation"
            } else if isEmailAlreadyMember {
                errorMessage = "This email address is already a member of the workspace"
            } else {
                errorMessage = "Please enter a valid email address"
            }
            showingError = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                // For demo purposes, create a local invitation without actual CloudKit sharing
                // In production, this would create and send a real CloudKit share
                
                // Mark workspace as shared (simulation)
                if !workspace.isShared {
                    workspace.shareURL = "https://www.icloud.com/share/demo-\(workspace.id)"
                    workspace.isShared = true
                    try modelContext.save()
                }
                
                // Create local invitation record for tracking
                let invitation = WorkspaceInvitation(
                    inviteeEmail: trimmedEmail,
                    workspace: workspace,
                    inviter: currentUser,
                    message: message.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                
                modelContext.insert(invitation)
                try modelContext.save()
                
                // Simulate CloudKit invitation process
                // Note: In production, you would pass a real CKShare object here
                print("Demo: Would send CloudKit invitation to \(trimmedEmail)")
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
                
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to send invitation: \(error.localizedDescription)"
                    showingError = true
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: SharedWorkspace.self, User.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let sampleUser = User(name: "John Doe", email: "john@example.com")
    let sampleWorkspace = SharedWorkspace(name: "Sample Workspace", owner: sampleUser)
    
    return InviteUserView(workspace: sampleWorkspace)
        .modelContainer(container)
} 