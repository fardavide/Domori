import SwiftUI
import SwiftData

struct SettingsView: View {
  var body: some View {
    NavigationView {
      Form {
        Section("Data Management") {
          NavigationLink(destination: ExportImportView()) {
            Label("Export & Import Properties", systemImage: "square.and.arrow.up.on.square")
          }
          
          HStack {
            Text("Storage")
            Spacer()
            Text("iCloud")
              .foregroundColor(.secondary)
          }
          
          Text("Your property data is automatically synced across all your devices using iCloud.")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        
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
        
        Section("About") {
          Text("Domori helps you manage and compare property listings with notes, photos, and ratings. Share your listings with others using CloudKit sharing.")
            .font(.caption)
            .foregroundColor(.secondary)
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
    .modelContainer(for: [PropertyListing.self], inMemory: true)
}
