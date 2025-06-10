import SwiftUI
import SwiftData

struct MainAppView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var shareURL: URL?
    @State private var showingShareAcceptance = false
    
    var body: some View {
        MainTabView()
            .onOpenURL { url in
                handleIncomingURL(url)
            }
            .sheet(isPresented: $showingShareAcceptance) {
                if let shareURL = shareURL {
                    ShareAcceptanceView(shareURL: shareURL)
                }
            }
    }
    
    private func handleIncomingURL(_ url: URL) {
        // Check if this is a CloudKit share URL
        if url.absoluteString.contains("icloud.com/share") {
            shareURL = url
            showingShareAcceptance = true
        }
    }
}

struct ShareAcceptanceView: View {
    let shareURL: URL
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var sharingService = SharingService.shared
    @State private var isAccepting = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("CloudKit Database Share Invitation")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("You've been invited to access shared property listings via CloudKit. Accepting will merge the shared database with yours - you'll be able to view and edit all shared properties, and changes will sync automatically.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                if isAccepting {
                    ProgressView("Accepting CloudKit share...")
                } else {
                    VStack(spacing: 12) {
                        Button("Accept CloudKit Share") {
                            acceptShare()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Decline") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                if let errorMessage = sharingService.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Share Invitation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func acceptShare() {
        isAccepting = true
        Task {
            await sharingService.acceptShare(from: shareURL, modelContext: modelContext)
            await MainActor.run {
                isAccepting = false
                dismiss()
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PropertyListView()
                .tabItem {
                    Label("Properties", systemImage: "house")
                }
                .tag(0)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(1)
        }
    }
}

#Preview {
  MainAppView()
    .modelContainer(for: [PropertyListing.self], inMemory: true)
}
