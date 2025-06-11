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
        if url.absoluteString.contains("icloud.com/share") || url.scheme == "https" && url.host?.contains("icloud.com") == true {
            shareURL = url
            showingShareAcceptance = true
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
