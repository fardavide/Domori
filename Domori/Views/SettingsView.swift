import SwiftUI

struct SettingsView: View {
  
  var appInformationSection: some View {
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
  
  var body: some View {
    NavigationView {
      Form {
        appInformationSection
      }
      .navigationTitle("Settings")
    }
  }
}

#Preview {
  SettingsView()
}
