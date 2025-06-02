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
        
        // Use CloudKit only on real devices, not in simulator
        #if targetEnvironment(simulator)
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        print("Running in simulator - using local storage")
        #else
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        print("Running on device - using CloudKit")
        #endif

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("ModelContainer creation failed: \(error)")
            // If CloudKit fails on device, fallback to local storage
            let fallbackConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
            do {
                print("Falling back to local storage...")
                return try ModelContainer(for: schema, configurations: [fallbackConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
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
