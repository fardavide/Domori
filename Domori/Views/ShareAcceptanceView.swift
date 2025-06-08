import SwiftUI
import CloudKit
import SwiftData

struct ShareAcceptanceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var cloudKitManager = CloudKitSharingManager.shared
    @State private var userManager = UserManager.shared
    
    let shareURL: URL
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var shareTitle = "Shared Workspace"
    @State private var shareOwner = "Unknown"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Share Icon
                Image(systemName: "person.2.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                VStack(alignment: .center, spacing: 16) {
                    Text("Collaboration Invitation")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("You've been invited to collaborate on:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 8) {
                        Text(shareTitle)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Shared by \(shareOwner)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("When you accept this invitation, you'll be able to:")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    ShareFeatureRow(icon: "eye", text: "View all shared properties")
                    ShareFeatureRow(icon: "plus.circle", text: "Add new properties to the shared workspace")
                    ShareFeatureRow(icon: "pencil", text: "Edit and rate properties together")
                    ShareFeatureRow(icon: "arrow.triangle.2.circlepath", text: "Sync changes across all devices")
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: acceptInvitation) {
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Accepting...")
                            }
                        } else {
                            Text("Accept Invitation")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(isLoading)
                    
                    Button("Decline") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .disabled(isLoading)
                }
            }
            .padding()
            .navigationTitle("Share Invitation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                loadShareMetadata()
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loadShareMetadata() {
        Task {
            // In a real implementation, you'd fetch share metadata
            // For now, use placeholder values
            await MainActor.run {
                shareTitle = "Shared Properties"
                shareOwner = "Property Owner"
            }
        }
    }
    
    private func acceptInvitation() {
        guard userManager.getCurrentUser(context: modelContext) != nil else {
            errorMessage = "Unable to find your account. Please restart the app and try again."
            showingError = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                // Accept the CloudKit share
                try await cloudKitManager.acceptShare(from: shareURL)
                
                // The shared data should now be available in the shared database
                // Fetch and integrate the shared workspace
                _ = try await cloudKitManager.fetchSharedWorkspaces()
                
                // Process shared workspaces (convert CloudKit records to SwiftData models)
                // This is a simplified version - in practice you'd need more sophisticated sync
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                    
                    // TODO: Navigate to the collaboration view to show the new shared workspace
                }
                
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to accept invitation: \(error.localizedDescription)"
                    showingError = true
                }
            }
        }
    }
}

private struct ShareFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}

#Preview {
    ShareAcceptanceView(shareURL: URL(string: "https://www.icloud.com/share/example")!)
} 