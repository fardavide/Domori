import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ExportImportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var workspaces: [SharedWorkspace]
    @State private var exportService = PropertyExportService.shared
    @State private var userManager = UserManager.shared
    
    @State private var showingExportPicker = false
    @State private var showingImportPicker = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var selectedWorkspace: SharedWorkspace?
    @State private var exportData: Data?
    @State private var replaceExistingOnImport = false
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Export Properties") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose a workspace to export properties from:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ForEach(availableWorkspaces, id: \.id) { workspace in
                            Button(action: {
                                selectedWorkspace = workspace
                                exportProperties(from: workspace)
                            }) {
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(.blue)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(workspace.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        if let count = workspace.properties?.count {
                                            Text("\(count) properties")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(.blue)
                                }
                                .padding(.vertical, 4)
                            }
                            .disabled(isProcessing)
                        }
                        
                        if availableWorkspaces.isEmpty {
                            Text("No workspaces available for export")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                }
                
                Section("Import Properties") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Import properties from a JSON file:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Toggle("Replace existing properties", isOn: $replaceExistingOnImport)
                            .font(.subheadline)
                        
                        if replaceExistingOnImport {
                            Text("⚠️ This will delete all existing properties in the selected workspace")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        Button(action: {
                            showingImportPicker = true
                        }) {
                            Label("Select File to Import", systemImage: "square.and.arrow.down")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isProcessing || availableWorkspaces.isEmpty)
                        
                        if availableWorkspaces.isEmpty {
                            Text("No workspaces available for import")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                }
                
                Section("File Format") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                            Text("JSON Format")
                                .font(.headline)
                        }
                        
                        Text("Properties are exported in JSON format, which can be opened with any text editor or imported back into the app. The export includes all property details, ratings, and tags.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                if isProcessing {
                    Section {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Processing...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Export & Import")
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
            .fileExporter(
                isPresented: $showingExportPicker,
                document: exportData.map { ExportDocument(data: $0) },
                contentType: .json,
                defaultFilename: defaultExportFilename
            ) { result in
                handleExportResult(result)
            }
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: PropertyExportService.supportedFileTypes,
                allowsMultipleSelection: false
            ) { result in
                handleImportResult(result)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var availableWorkspaces: [SharedWorkspace] {
        return workspaces.filter { $0.isActive }
    }
    
    private var defaultExportFilename: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        
        let workspaceName = selectedWorkspace?.name.replacingOccurrences(of: " ", with: "_") ?? "Properties"
        return "\(workspaceName)_Export_\(dateString).json"
    }
    
    // MARK: - Export Functions
    
    private func exportProperties(from workspace: SharedWorkspace) {
        isProcessing = true
        
        Task {
            do {
                let data = try exportService.exportWorkspaceListings(workspace: workspace, context: modelContext)
                
                await MainActor.run {
                    self.exportData = data
                    self.showingExportPicker = true
                    self.isProcessing = false
                }
            } catch {
                await MainActor.run {
                    self.showExportError(error)
                    self.isProcessing = false
                }
            }
        }
    }
    
    private func handleExportResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            alertTitle = "Export Successful"
            alertMessage = "Properties have been exported to: \(url.lastPathComponent)"
            showingAlert = true
        case .failure(let error):
            showExportError(error)
        }
    }
    
    private func showExportError(_ error: Error) {
        alertTitle = "Export Failed"
        alertMessage = "Failed to export properties: \(error.localizedDescription)"
        showingAlert = true
    }
    
    // MARK: - Import Functions
    
    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            importProperties(from: url)
        case .failure(let error):
            showImportError(error)
        }
    }
    
    private func importProperties(from url: URL) {
        isProcessing = true
        
        print("🚀 Starting import from URL: \(url)")
        
        Task {
            do {
                // iOS requires security-scoped access to imported files
                print("🔐 Requesting security scoped access...")
                guard url.startAccessingSecurityScopedResource() else {
                    print("❌ Security scoped access FAILED")
                    throw NSError(domain: "ImportError", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: "Unable to access the selected file. Please try selecting the file again."
                    ])
                }
                
                print("✅ Security scoped access granted")
                
                defer {
                    print("🔒 Stopping security scoped access")
                    url.stopAccessingSecurityScopedResource()
                }
                
                print("📂 Reading file data...")
                let data = try Data(contentsOf: url)
                print("✅ File read successfully, size: \(data.count) bytes")
                
                // Debug: Print raw file content
                if let content = String(data: data, encoding: .utf8) {
                    print("📄 File content preview: \(content.prefix(200))")
                } else {
                    print("❌ Could not read file as UTF-8 string")
                }
                
                // Validate the data first
                print("🔍 Starting validation...")
                let validation = exportService.validateImportData(data)
                print("📋 Validation result: isValid=\(validation.isValid), error=\(validation.error ?? "none")")
                
                await MainActor.run {
                    if validation.isValid {
                        print("✅ Validation passed, showing confirmation")
                        self.showImportConfirmation(data: data, validation: validation)
                    } else {
                        print("❌ Validation failed: \(validation.error ?? "Invalid file format")")
                        self.showImportValidationError(validation.error ?? "Invalid file format")
                    }
                    self.isProcessing = false
                }
            } catch {
                print("💥 Import failed with error: \(error)")
                await MainActor.run {
                    self.showImportError(error)
                    self.isProcessing = false
                }
            }
        }
    }
    
    private func showImportConfirmation(data: Data, validation: ValidationResult) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let exportDateString = validation.exportDate.map { formatter.string(from: $0) } ?? "Unknown"
        
        alertTitle = "Confirm Import"
        alertMessage = """
        Found \(validation.listingCount) properties
        Export date: \(exportDateString)
        Version: \(validation.version ?? "Unknown")
        
        Choose a workspace to import to:
        """
        
        // Show workspace selection for import
        showWorkspaceSelectionForImport(data: data)
    }
    
    private func showWorkspaceSelectionForImport(data: Data) {
        // Ensure current user has a workspace, then use it for import
        let workspace: SharedWorkspace
        
        if let currentUser = userManager.getCurrentUser(context: modelContext) {
            // Ensure user has a primary workspace
            if currentUser.primaryWorkspace == nil {
                print("🏠 Current user has no workspace, creating one...")
                currentUser.createPersonalWorkspace(context: modelContext)
                do {
                    try modelContext.save()
                } catch {
                    print("❌ Error saving workspace: \(error)")
                }
            }
            
            if let primaryWorkspace = currentUser.primaryWorkspace {
                workspace = primaryWorkspace
                print("📝 Using current user's primary workspace: \(workspace.name)")
            } else {
                print("❌ Failed to create/find primary workspace, creating fallback...")
                workspace = createFallbackWorkspace()
            }
        } else {
            print("❌ No current user found, creating fallback workspace...")
            workspace = createFallbackWorkspace()
        }
        
        performImport(data: data, workspace: workspace)
    }
    
    private func createFallbackWorkspace() -> SharedWorkspace {
        // This should only be called as an absolute last resort
        print("🆘 Creating emergency fallback workspace...")
        
        // Try to get or create the current user
        let currentUser: User
        
        if let existingUser = userManager.getCurrentUser(context: modelContext) {
            currentUser = existingUser
        } else if let userManagerUser = userManager.currentUser {
            // Create user in database if they don't exist
            let newUser = User(name: userManagerUser.name, email: userManagerUser.email)
            newUser.id = userManagerUser.id
            modelContext.insert(newUser)
            currentUser = newUser
        } else {
            // Ultimate fallback - this should never happen
            let fallbackUser = User(name: "iCloud User", email: "user@icloud.com")
            modelContext.insert(fallbackUser)
            currentUser = fallbackUser
        }
        
        // Create a simple workspace
        let fallbackWorkspace = SharedWorkspace(
            name: "My Properties",
            owner: currentUser
        )
        modelContext.insert(fallbackWorkspace)
        
        do {
            try modelContext.save()
            print("✅ Created fallback workspace for: \(currentUser.email)")
        } catch {
            print("❌ Failed to save fallback workspace: \(error)")
        }
        
        return fallbackWorkspace
    }
    
    private func performImport(data: Data, workspace: SharedWorkspace) {
        isProcessing = true
        
        Task {
            let result = exportService.importListings(
                from: data,
                toWorkspace: workspace,
                context: modelContext,
                replaceExisting: replaceExistingOnImport
            )
            
            await MainActor.run {
                self.handleImportResultCompletion(result)
                self.isProcessing = false
            }
        }
    }
    
    private func handleImportResultCompletion(_ result: ImportResult) {
        if result.success {
            alertTitle = "Import Successful"
            alertMessage = result.message
            if result.skippedCount > 0 {
                alertMessage += "\n\nSkipped \(result.skippedCount) properties due to errors."
            }
        } else {
            alertTitle = "Import Failed"
            alertMessage = result.message
        }
        showingAlert = true
    }
    
    private func showImportError(_ error: Error) {
        alertTitle = "Import Failed"
        alertMessage = "Failed to import properties: \(error.localizedDescription)"
        showingAlert = true
    }
    
    private func showImportValidationError(_ error: String) {
        alertTitle = "Invalid File"
        alertMessage = "The selected file is not a valid property export: \(error)"
        showingAlert = true
    }
}

// MARK: - Export Document

struct ExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - Preview

#Preview {
    ExportImportView()
        .modelContainer(for: [PropertyListing.self, SharedWorkspace.self, PropertyTag.self])
} 