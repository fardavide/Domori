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
    print("DataMigration: Property rating migration needed - starting migration process...")
    await DataMigrationManager.migratePropertyListings(context: context)
  }
}
