import SwiftUI
import SwiftData
import CloudKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var sharingCoordinator: SharingCoordinator
    
    @State private var showImportAlert = false
    @State private var importResult: ImportResult?
    @State private var importError: String?
    
    var body: some View {
        MainTabView()
            .sheet(isPresented: $sharingCoordinator.showShareImport) {
                if let url = sharingCoordinator.sharedURL {
                    ImportSharedDatabaseView(url: url) { result in
                        sharingCoordinator.showShareImport = false
                        
                        switch result {
                        case .success(let importResult):
                            self.importResult = importResult
                            self.showImportAlert = true
                        case .failure(let error):
                            self.importError = error.localizedDescription
                            self.showImportAlert = true
                        }
                    }
                }
            }
            .alert(isPresented: $showImportAlert) {
                if let error = importError {
                    return Alert(
                        title: Text("Import Failed"),
                        message: Text(error),
                        dismissButton: .default(Text("OK"))
                    )
                } else if let result = importResult {
                    return Alert(
                        title: Text("Import Complete"),
                        message: Text("Successfully imported \(result.importedCount) properties" +
                                     (result.skippedCount > 0 ? " (skipped \(result.skippedCount))" : "")),
                        dismissButton: .default(Text("OK"))
                    )
                } else {
                    return Alert(
                        title: Text("Import"),
                        message: Text("Unknown status"),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
    }
}

struct ImportSharedDatabaseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let url: URL
    let onComplete: (Result<ImportResult, Error>) -> Void
    
    @State private var isImporting = true
    
    var body: some View {
        VStack {
            Text("Importing Shared Database")
                .font(.headline)
                .padding()
            
            if isImporting {
                ProgressView()
                    .padding()
                
                Text("Please wait while the shared database is being imported...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            importDatabase()
        }
    }
    
    private func importDatabase() {
        DatabaseSharingService.shared.acceptShare(from: url, context: modelContext) { result in
            DispatchQueue.main.async {
                isImporting = false
                onComplete(result)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [PropertyListing.self], inMemory: true)
        .environmentObject(SharingCoordinator())
} 