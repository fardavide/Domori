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
        }
        .modelContainer(sharedModelContainer)
        
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
