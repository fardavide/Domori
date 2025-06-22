import SwiftUI
import UniformTypeIdentifiers
import FirebaseFirestore

struct ExportImportView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.firestore) private var firestore
  
  @FirestoreQuery private var allProperties: [Property]
  @State private var exportService = PropertyExportService.shared
  
  @State private var showingExportPicker = false
  @State private var showingImportPicker = false
  @State private var showingAlert = false
  @State private var alertTitle = ""
  @State private var alertMessage = ""
  @State private var exportData: Data?
  @State private var replaceExistingOnImport = false
  @State private var isProcessing = false
  
  var body: some View {
    NavigationView {
      Form {
        Section("Export Properties") {
          VStack(alignment: .leading, spacing: 12) {
            Text("Export all your property listings to a JSON file:")
              .font(.caption)
              .foregroundColor(.secondary)
            
            HStack {
              Image(systemName: "house.fill")
                .foregroundColor(.blue)
              
              VStack(alignment: .leading, spacing: 2) {
                Text("All Properties")
                  .font(.headline)
                  .foregroundColor(.primary)
                
                Text("\(allProperties.count) properties")
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              
              Spacer()
              
              Button(action: {
                exportProperties()
              }) {
                Label("Export", systemImage: "square.and.arrow.up")
              }
              .buttonStyle(.borderedProminent)
              .disabled(isProcessing || allProperties.isEmpty)
            }
            .padding(.vertical, 4)
            
            if allProperties.isEmpty {
              Text("No properties available for export")
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
              Text("⚠️ This will delete all existing properties")
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
            .disabled(isProcessing)
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
  
  private var defaultExportFilename: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dateString = formatter.string(from: Date())
    return "Export_\(dateString).json"
  }
  
  // MARK: - Export Functions
  
  private func exportProperties() {
    isProcessing = true
    
    Task {
      do {
        let data = try await exportService.exportAllListings(firestore: firestore)
        
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
        
        await MainActor.run {
          switch validation {
          case .valid: self.performImport(data: data)
          case .invalid(error: let error): self.showImportValidationError(error)
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
  
  private func performImport(data: Data) {
    isProcessing = true
    
    Task {
      let result = exportService.importListings(
        from: data,
        firestore: firestore
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
  
  private func showImportValidationError(_ error: Error) {
    alertTitle = "Invalid File"
    alertMessage = "The selected file is not a valid property export: \(error.localizedDescription)"
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
