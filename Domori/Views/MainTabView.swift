import SwiftUI
import SwiftData

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
  MainTabView()
    .modelContainer(for: [PropertyListing.self], inMemory: true)
}
