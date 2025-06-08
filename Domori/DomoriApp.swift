//

import SwiftUI
import SwiftData

@main
struct DomoriApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PropertyListing.self,
            PropertyTag.self,
            User.self,
            SharedWorkspace.self,
            WorkspaceInvitation.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
          fatalError("CloudKit ModelContainer init failed: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainAppView()
                .onAppear {
                    // Perform data migration on app startup
                    Task {
                        await performDataMigration()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
        
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
    
    @MainActor
    private func performDataMigration() async {
        let context = sharedModelContainer.mainContext
        
        // Check if property rating migration is needed
        if DataMigrationManager.needsMigration(context: context) {
            print("DataMigration: Property rating migration needed - starting migration process...")
            await DataMigrationManager.migratePropertyListings(context: context)
            
            // Validate migration was successful
            _ = DataMigrationManager.validateMigration(context: context)
        } else {
            print("DataMigration: No property rating migration needed")
        }
        
        // Check if Photos and Notes removal migration is needed
        if DataMigrationManager.needsPhotosAndNotesRemoval(context: context) {
            print("DataMigration: Photos and Notes removal migration needed - starting removal process...")
            await DataMigrationManager.removePhotosAndNotesFeatures(context: context)
            
            // Validate removal was successful
            _ = DataMigrationManager.validatePhotosAndNotesRemoval(context: context)
        } else {
            print("DataMigration: No Photos and Notes removal needed")
        }
    }
}
