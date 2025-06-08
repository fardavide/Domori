import SwiftUI
import SwiftData

struct MainAppView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var userManager = UserManager.shared
    @State private var showingShareAcceptance = false
    @State private var shareURL: URL?
    @State private var hasInitializedUser = false
    @State private var isCheckingAuthentication = true
    
    var body: some View {
        Group {
            if isCheckingAuthentication {
                // Show loading while checking iCloud authentication
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Connecting to iCloud...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
            } else {
                MainTabView()
            }
        }
        .onOpenURL { url in
            handleIncomingURL(url)
        }
        .sheet(isPresented: $showingShareAcceptance) {
            if let shareURL = shareURL {
                ShareAcceptanceView(shareURL: shareURL)
            }
        }
        .onAppear {
            checkAuthenticationStatus()
        }
        .onChange(of: userManager.isSignedIn) { _, isSignedIn in
            if isSignedIn {
                ensureUserInDatabase()
                isCheckingAuthentication = false
            }
        }
    }
    
    private func checkAuthenticationStatus() {
        // Wait a moment for iCloud authentication to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if userManager.isSignedIn {
                ensureUserInDatabase()
                isCheckingAuthentication = false
            } else {
                // If still not signed in after waiting, create a default user
                createDefaultUser()
                isCheckingAuthentication = false
            }
        }
    }
    
    private func createDefaultUser() {
        // Create a default local user if iCloud is not available
        userManager.createDefaultUser()
        ensureUserInDatabase()
    }
    
    private func ensureUserInDatabase() {
        // Only run once and only if user is signed in
        guard !hasInitializedUser, userManager.isSignedIn, let currentUser = userManager.currentUser else {
            return
        }
        
        hasInitializedUser = true
        
        // Check if user already exists in database
        let userEmail = currentUser.email
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { user in
                user.email == userEmail
            }
        )
        
        do {
            let existingUsers = try modelContext.fetch(descriptor)
            if existingUsers.isEmpty {
                // Create user in database
                let dbUser = User(name: currentUser.name, email: currentUser.email)
                dbUser.id = currentUser.id // Keep the same ID
                modelContext.insert(dbUser)
                try modelContext.save()
                
                // Create personal workspace for user
                dbUser.createPersonalWorkspace(context: modelContext)
                try modelContext.save()
                
                print("MainAppView: Created iCloud user in database - \(currentUser.name)")
            } else {
                // User exists, ensure they have a personal workspace
                if let existingUser = existingUsers.first {
                    existingUser.createPersonalWorkspace(context: modelContext)
                    try modelContext.save()
                }
                print("MainAppView: iCloud user already exists in database - \(currentUser.name)")
            }
        } catch {
            print("MainAppView: Error ensuring user in database - \(error.localizedDescription)")
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

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
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
        .modelContainer(for: [PropertyListing.self, User.self, SharedWorkspace.self], inMemory: true)
} 