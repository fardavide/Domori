import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("App Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Data") {
                    HStack {
                        Text("Properties")
                        Spacer()
                        Text("Stored in iCloud")
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Your property data is automatically synced across all your devices using iCloud.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("About") {
                    Text("Domori helps you manage and compare property listings with notes, photos, and ratings.")
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
        }
    }
}

#Preview {
    SettingsView()
} 