import SwiftUI
import SwiftData

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @State private var showingShareSheet = false
  
  var body: some View {
    NavigationView {
      Form {
        Section("Sharing") {
          Button(action: {
            showingShareSheet = true
          }) {
            Label("Share All Properties", systemImage: "square.and.arrow.up")
              .foregroundColor(.blue)
          }
          
          Text("Share all your property listings with another person. They will be able to view and edit all properties.")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        
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
            Text("1.1")
              .foregroundColor(.secondary)
          }
          
          HStack {
            Text("Build")
            Spacer()
            Text("4")
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
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button("Done") {
            dismiss()
          }
        }
      }
      .sheet(isPresented: $showingShareSheet) {
        SharingView()
      }
    }
  }
}

#Preview {
  SettingsView()
    .modelContainer(for: [PropertyListing.self], inMemory: true)
}
