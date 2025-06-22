import SwiftUI

struct SettingsView: View {
  var body: some View {
    NavigationView {
      Form {
        Section("App Information") {
          HStack {
            Text("Version")
            Spacer()
            Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
              .foregroundColor(.secondary)
          }
          
          HStack {
            Text("Build")
            Spacer()
            Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)
              .foregroundColor(.secondary)
          }
        }
      }
      .navigationTitle("Settings")
#if os(iOS)
      .navigationBarTitleDisplayMode(.large)
#endif
    }
  }
}

#Preview {
  SettingsView()
}
