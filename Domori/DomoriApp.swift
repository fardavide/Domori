//

import SwiftUI
import SwiftData

@main
struct DomoriApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PropertyListing.self,
            PropertyNote.self,
            PropertyPhoto.self,
            PropertyTag.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
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
        
        // Check if migration is needed
        if DataMigrationManager.needsMigration(context: context) {
            print("DataMigration: Migration needed - starting migration process...")
            await DataMigrationManager.migratePropertyListings(context: context)
            
            // Validate migration was successful
            _ = DataMigrationManager.validateMigration(context: context)
        } else {
            print("DataMigration: No migration needed")
        }
    }
}
