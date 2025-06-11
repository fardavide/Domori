import SwiftUI
import SwiftData
import CloudKit
#if canImport(UIKit)
import UIKit
#endif

struct DatabaseSharingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var sharingURL: URL?
    @State private var isGeneratingLink = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var shareResult: ImportResult?
    @State private var showShareImportResult = false
    @State private var showShareLinkPicker = false
    @State private var showSchemaInfo = false
    
    @State private var importURL = ""
    @State private var isProcessingImport = false
    @State private var isSimulator = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Share Your Database")) {
                    Button(action: generateSharingLink) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share My Property Database")
                        }
                    }
                    .disabled(isGeneratingLink)
                    
                    if isGeneratingLink {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    }
                    
                    if let shareURL = sharingURL {
                        Text("Share this URL: \(shareURL.absoluteString)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                            .truncationMode(.middle)
                            .textSelection(.enabled)
                    }
                    
                    #if targetEnvironment(simulator)
                    Text("Running in simulator - CloudKit operations are simulated")
                        .font(.caption)
                        .foregroundColor(.orange)
                    #endif
                    
                    if let status = DatabaseSharingService.shared.schemaStatus, !status.isEmpty {
                        Button(action: { showSchemaInfo = true }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(status.contains("issue") ? .orange : .green)
                                Text("CloudKit Schema Status")
                                    .foregroundColor(status.contains("issue") ? .orange : .primary)
                            }
                        }
                    }
                }
                
                Section(header: Text("Accept Shared Database")) {
                    TextField("Enter sharing URL", text: $importURL)
                        .disableAutocorrection(true)
                    
                    Button(action: importFromURL) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Import Shared Database")
                        }
                    }
                    .disabled(importURL.isEmpty || isProcessingImport)
                    
                    if isProcessingImport {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    }
                }
                
                Section(header: Text("About Database Sharing")) {
                    Text("Sharing your database will allow other Domori users to access and import your properties into their app. Databases are merged, so both users will have access to the combined set of properties.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Share Database")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
            .alert("Import Complete", isPresented: $showShareImportResult) {
                Button("OK") { }
            } message: {
                if let result = shareResult {
                    Text("Successfully imported \(result.importedCount) properties" + (result.skippedCount > 0 ? " (skipped \(result.skippedCount))" : ""))
                } else {
                    Text("Import completed")
                }
            }
            .sheet(isPresented: $showSchemaInfo) {
                SchemaInfoView()
            }
            #if os(iOS)
            .sheet(isPresented: $showShareLinkPicker) {
                if let url = sharingURL {
                    ShareSheet(items: [url])
                }
            }
            #endif
            .onAppear {
                #if targetEnvironment(simulator)
                isSimulator = true
                #endif
            }
        }
    }
    
    private func generateSharingLink() {
        isGeneratingLink = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                let url = try await withCheckedThrowingContinuation { continuation in
                    DatabaseSharingService.shared.exportAndShareDatabase(context: modelContext) { result in
                        continuation.resume(with: result)
                    }
                }
                
                isGeneratingLink = false
                self.sharingURL = url
                #if os(iOS) && !targetEnvironment(simulator)
                self.showShareLinkPicker = true
                #elseif os(iOS) && targetEnvironment(simulator)
                // In simulator, just show the URL
                print("Simulated share URL: \(url.absoluteString)")
                #endif
            } catch {
                isGeneratingLink = false
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
    
    private func importFromURL() {
        var urlToUse = importURL
        
        #if targetEnvironment(simulator)
        // In simulator, any URL will work
        if urlToUse.isEmpty || !urlToUse.starts(with: "http") {
            urlToUse = "https://icloud.com/share/simulator-mock-share-\(UUID().uuidString)"
        }
        #endif
        
        guard let url = URL(string: urlToUse) else {
            errorMessage = "Invalid URL format"
            showError = true
            return
        }
        
        isProcessingImport = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                let result = try await withCheckedThrowingContinuation { continuation in
                    DatabaseSharingService.shared.acceptShare(from: url, context: modelContext) { result in
                        continuation.resume(with: result)
                    }
                }
                
                isProcessingImport = false
                self.shareResult = result
                self.showShareImportResult = true
                self.importURL = ""
            } catch {
                isProcessingImport = false
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
}

struct SchemaInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var status = DatabaseSharingService.shared.schemaStatus ?? "Checking schema status..."
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("CloudKit Schema Status")
                    .font(.headline)
                
                Text(status)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)))
                
                if status.contains("issue") || status.contains("deployed to production") {
                    Text("How to resolve schema issues:")
                        .font(.headline)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("1. Log in to the Apple Developer Portal")
                        Text("2. Go to CloudKit Dashboard > Your Container")
                        Text("3. Select 'Schema' from the sidebar")
                        Text("4. Click 'Deploy Schema Changes to Production'")
                        Text("5. Verify all record types and fields are deployed")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue.opacity(0.1)))
                    
                    Text("Note: The app will automatically use a fallback method to share your database until the schema is fully deployed.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("CloudKit Schema")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button(action: refreshSchemaStatus) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
    
    private func refreshSchemaStatus() {
        status = "Checking schema status..."
        
        Task { @MainActor in
            do {
                try await DatabaseSharingService.shared.checkAndPrepareSchema()
                status = DatabaseSharingService.shared.schemaStatus ?? "Unknown status"
            } catch {
                status = "Error checking schema: \(error.localizedDescription)"
            }
        }
    }
}

#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Nothing to update
    }
}
#endif

#Preview {
    DatabaseSharingView()
        .modelContainer(for: [PropertyListing.self], inMemory: true)
} 
