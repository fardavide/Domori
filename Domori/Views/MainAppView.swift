import SwiftUI
import SwiftData

struct MainAppView: View {
  @Environment(\.modelContext) private var modelContext
  
  var body: some View {
    MainTabView()
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
