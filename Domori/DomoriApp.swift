import SwiftUI
import SwiftData
import CloudKit

@main
struct DomoriApp: App {
    @State private var migrationManager = DataMigrationManager()
    @StateObject private var sharingCoordinator = SharingCoordinator()
    private static let isTest = ProcessInfo.processInfo.arguments.contains("test")
    
    static let schema = Schema([
        PropertyListing.self,
        PropertyTag.self
    ])
    
    var sharedModelContainer: ModelContainer = {
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: isTest,
            // Configure CloudKit database with explicit container ID to prevent multiple instances
            cloudKitDatabase: isTest ? .none : .private("iCloud.fardavide.Domori")
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("CloudKit ModelContainer init failed: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            if DomoriApp.isTest {
                Text("Running unit tests")
            } else {
                ContentView()
                    .onAppear {
                        Task {
                            await performDataMigration()
                        }
                    }
                    .onOpenURL { url in
                        sharingCoordinator.handleIncomingURL(url)
                    }
            }
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(sharingCoordinator)
        
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
    
    private func performDataMigration() async {
        let context = sharedModelContainer.mainContext
        await DataMigrationManager.migratePropertyListings(context: context)
    }
}

class SharingCoordinator: ObservableObject {
    @Published var sharedURL: URL?
    @Published var showShareImport = false
    
    func handleIncomingURL(_ url: URL) {
        // Check if this is a CloudKit sharing URL
        if url.scheme == "cloudkit-icloud.fardavide.Domori" || 
           url.absoluteString.contains("icloud.com") {
            sharedURL = url
            showShareImport = true
        }
    }
}
