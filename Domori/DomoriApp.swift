import SwiftUI
import SwiftData
import CloudKit

@main
struct DomoriApp: App {
  
  private static let isTest = ProcessInfo.processInfo.arguments.contains("test")
  
  static let schema = Schema([
    PropertyListing.self,
    PropertyTag.self
  ])
  
  var sharedModelContainer: ModelContainer = {
    let modelConfiguration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: isTest,
      cloudKitDatabase: isTest ? .none : .automatic
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
