//

import SwiftUI
import SwiftData

@main
struct DomoriApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PropertyListing.self,
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
