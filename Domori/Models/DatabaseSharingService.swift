import Foundation
import SwiftUI
import SwiftData
import CloudKit
#if canImport(UIKit)
import UIKit
#endif

enum SharingError: Error, LocalizedError {
    case cloudKitNotAvailable
    case sharingRecordCreationFailed
    case sharingSetupFailed
    case fetchRecordFailed
    case participantAddFailed
    case recordNotFound
    case schemaMismatch(String)
    
    var errorDescription: String? {
        switch self {
        case .cloudKitNotAvailable:
            return "iCloud is not available. Please sign in to your iCloud account."
        case .sharingRecordCreationFailed:
            return "Failed to create sharing record."
        case .sharingSetupFailed:
            return "Failed to set up sharing."
        case .fetchRecordFailed:
            return "Failed to fetch record."
        case .participantAddFailed:
            return "Failed to add participant."
        case .recordNotFound:
            return "Record not found."
        case .schemaMismatch(let message):
            return "CloudKit schema issue: \(message). Please try again later or contact support."
        }
    }
}

@Observable
final class DatabaseSharingService {
    static let shared = DatabaseSharingService()
    
    private let container: CKContainer
    var schemaCheckCompleted = false
    var schemaStatus: String?
    
    private init() {
        let containerIdentifier = "iCloud.fardavide.Domori"
        container = CKContainer(identifier: containerIdentifier)
        
        // Check schema on initialization
        Task { @MainActor in
            try? await checkAndPrepareSchema()
        }
    }
    
    var isCloudKitAvailable: Bool {
#if targetEnvironment(simulator)
        return true
#else
        return FileManager.default.ubiquityIdentityToken != nil
#endif
    }
    
    // MARK: - Schema Management
    
    @MainActor
    func checkAndPrepareSchema() async throws {
        #if targetEnvironment(simulator)
        schemaCheckCompleted = true
        schemaStatus = "Simulator - Schema checks skipped"
        return
        #else
        guard isCloudKitAvailable else {
            schemaStatus = "iCloud not available"
            return
        }
        
        do {
            let database = container.privateCloudDatabase
            let requiredRecordTypes = ["DomoriDatabaseExport", "SharedDomoriDatabase"]
            let requiredFields: [String: [String]] = [
                "DomoriDatabaseExport": ["exportData", "exportDate", "recordType", "name", "version"],
                "SharedDomoriDatabase": ["name", "version"]
            ]
            
            // Check each record type
            for recordType in requiredRecordTypes {
                let sampleRecord = CKRecord(recordType: recordType)
                
                // Add required fields to test if they're available
                if let fields = requiredFields[recordType] {
                    for field in fields {
                        // Use different value types based on field name
                        if field == "exportDate" {
                            sampleRecord[field] = Date() as CKRecordValue
                        } else if field == "version" {
                            sampleRecord[field] = 1 as CKRecordValue
                        } else if field == "exportData" {
                            // Create a temporary file for testing
                            let tempDir = FileManager.default.temporaryDirectory
                            let fileURL = tempDir.appendingPathComponent("schema_test_\(UUID().uuidString).txt")
                            try "Schema test".write(to: fileURL, atomically: true, encoding: .utf8)
                            sampleRecord[field] = CKAsset(fileURL: fileURL)
                        } else {
                            sampleRecord[field] = "Schema test" as CKRecordValue
                        }
                    }
                }
                
                // Try to save the record to test schema compatibility
                do {
                    let _ = try await database.save(sampleRecord)
                    print("Schema check for \(recordType) passed")
                    
                    // Delete the test record
                    try await database.deleteRecord(withID: sampleRecord.recordID)
                } catch let error as CKError {
                    let errorDescription = error.localizedDescription
                    
                    if error.code == .serverRejectedRequest && 
                       (errorDescription.contains("field") && errorDescription.contains("schema")) {
                        
                        // This is likely a schema mismatch error
                        schemaStatus = "Schema issue with \(recordType): \(errorDescription)"
                        print("⚠️ \(schemaStatus!)")
                    } else if error.code == .unknownItem {
                        // Record type might not exist in production yet
                        schemaStatus = "Record type \(recordType) may need to be deployed to production"
                        print("⚠️ \(schemaStatus!)")
                    } else {
                        throw error
                    }
                }
            }
            
            schemaCheckCompleted = true
            if schemaStatus == nil {
                schemaStatus = "Schema check completed successfully"
            }
        } catch {
            schemaStatus = "Schema check failed: \(error.localizedDescription)"
            print("❌ Schema check error: \(error.localizedDescription)")
            throw error
        }
        #endif
    }
    
    // MARK: - Sharing
    
    func createSharingLink(completion: @escaping (Result<URL, Error>) -> Void) {
        guard isCloudKitAvailable else {
            completion(.failure(SharingError.cloudKitNotAvailable))
            return
        }
        
#if targetEnvironment(simulator)
        // Create a mock sharing URL for the simulator
        let mockURL = URL(string: "https://icloud.com/share/simulator-mock-share-\(UUID().uuidString)")!
        completion(.success(mockURL))
#else
        // Create a share record to represent the shared database
        let rootRecord = CKRecord(recordType: "SharedDomoriDatabase")
        rootRecord["name"] = "Domori Property Database" as CKRecordValue
        rootRecord["version"] = 1 as CKRecordValue
        
        // Create a share for this record
        let shareRecord = CKShare(rootRecord: rootRecord)
        shareRecord[CKShare.SystemFieldKey.title] = "Domori Property Database" as CKRecordValue
        shareRecord[CKShare.SystemFieldKey.shareType] = "fardavide.Domori.database" as CKRecordValue
        
        // Save both the root record and share in the same operation
        let operation = CKModifyRecordsOperation(recordsToSave: [rootRecord, shareRecord])
        operation.savePolicy = .changedKeys
        
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success:
                print("Share created successfully")
                let sharingURL = self.createSharingURL(for: shareRecord)
                completion(.success(sharingURL))
            case .failure(let error):
                print("Error creating share: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        container.privateCloudDatabase.add(operation)
#endif
    }
    
    func exportAndShareDatabase(context: ModelContext, completion: @escaping (Result<URL, Error>) -> Void) {
        do {
            // Export all properties to JSON format
            let exportData = try PropertyExportService.shared.exportAllListings(context: context)
            
#if targetEnvironment(simulator)
            // For simulator, create a simulated share URL
            print("CloudKit operations are simulated in the simulator")
            
            // Save data to temporary file for debugging purposes
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("domori_export_\(UUID().uuidString).json")
            try exportData.write(to: fileURL)
            print("Saved mock export data to: \(fileURL.path)")
            
            // Create a mock share URL
            let mockShareURL = URL(string: "https://icloud.com/share/domori-database-\(UUID().uuidString)")!
            
            // Simulate a delay to make it feel like a network operation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion(.success(mockShareURL))
            }
#else
            // Check if we know there are schema issues
            if let status = schemaStatus, status.contains("Schema issue") || status.contains("deployed to production") {
                // Try alternative approach with default record type
                self.exportWithDefaultRecordType(exportData: exportData, completion: completion)
                return
            }
            
            // Create a CloudKit record with this data
            let databaseRecord = CKRecord(recordType: "CKDefaultRecordType")  // Use default type
            
            // Create a temporary file URL
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("domori_export_\(UUID().uuidString).json")
            
            try exportData.write(to: fileURL)
            
            // Attach the file to the record
            let asset = CKAsset(fileURL: fileURL)
            databaseRecord["asset"] = asset
            databaseRecord["date"] = Date() as CKRecordValue
            databaseRecord["description"] = "Domori Property Database Export" as CKRecordValue
            
            // Create a share for this record
            let share = CKShare(rootRecord: databaseRecord)
            share[CKShare.SystemFieldKey.title] = "Domori Property Database" as CKRecordValue
            
            // Create an operation to save both the record and share
            let operation = CKModifyRecordsOperation(recordsToSave: [databaseRecord, share])
            operation.savePolicy = .changedKeys
            
            operation.modifyRecordsResultBlock = { result in
                // Delete the temporary file
                try? FileManager.default.removeItem(at: fileURL)
                
                switch result {
                case .success:
                    let sharingURL = self.createSharingURL(for: share)
                    completion(.success(sharingURL))
                case .failure(let error):
                    if let ckError = error as? CKError {
                        let errorDescription = ckError.localizedDescription
                        
                        // If we get a field schema error, try the fallback approach
                        if ckError.code == .serverRejectedRequest &&
                           ((errorDescription.contains("field") && errorDescription.contains("schema")) ||
                           errorDescription.contains("Cannot create")) {
                            
                            print("Schema error detected: \(errorDescription), trying fallback...")
                            self.exportWithDefaultRecordType(exportData: exportData, completion: completion)
                            return
                        }
                    }
                    
                    print("Error saving database record: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            
            container.privateCloudDatabase.add(operation)
#endif
        } catch {
            print("Error exporting database: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    // Fallback method for exporting when schema has issues
    private func exportWithDefaultRecordType(exportData: Data, completion: @escaping (Result<URL, Error>) -> Void) {
        do {
            // Use a more basic approach with built-in record types and fields
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("domori_export_\(UUID().uuidString).json")
            try exportData.write(to: fileURL)
            
            // Create a record with a default type and minimal fields
            let defaultRecord = CKRecord(recordType: "CKDefaultRecordType")
            defaultRecord["asset"] = CKAsset(fileURL: fileURL)  // Use a standard field name
            defaultRecord["date"] = Date() as CKRecordValue
            defaultRecord["description"] = "Domori Property Database Export" as CKRecordValue
            
            // Create a share for this record
            let share = CKShare(rootRecord: defaultRecord)
            share[CKShare.SystemFieldKey.title] = "Domori Property Database" as CKRecordValue
            
            // Create an operation to save both the record and share
            let operation = CKModifyRecordsOperation(recordsToSave: [defaultRecord, share])
            operation.savePolicy = .changedKeys
            
            operation.modifyRecordsResultBlock = { result in
                // Delete the temporary file
                try? FileManager.default.removeItem(at: fileURL)
                
                switch result {
                case .success:
                    let sharingURL = self.createSharingURL(for: share)
                    completion(.success(sharingURL))
                case .failure(let error):
                    print("Error in fallback save: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            
            container.privateCloudDatabase.add(operation)
        } catch {
            print("Error in fallback export: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    // MARK: - Accepting Shares
    
    @MainActor
    func acceptShare(from url: URL, context: ModelContext, completion: @escaping (Result<ImportResult, Error>) -> Void) {
        // For the mock/demo implementation, we'll generate some sample data
        // and import it directly instead of using CloudKit sharing
        
        do {
            // Create some sample export data
            let sampleProperty = PropertyListing(
                title: "Shared Property",
                location: "Shared Location",
                link: "https://example.com/shared",
                agentContact: "shared@example.com",
                price: 450000,
                size: 115.0,
                bedrooms: 3,
                bathrooms: 1.5,
                propertyType: .apartment,
                propertyRating: .good
            )
            
            // Create a temporary in-memory container
            let schema = Schema([PropertyListing.self, PropertyTag.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try! ModelContainer(for: schema, configurations: [configuration])
            let tempContext = container.mainContext
            tempContext.insert(sampleProperty)
            
            let exportData = try PropertyExportService.shared.exportAllListings(context: tempContext)
            
            // Import the sample data
            let importResult = PropertyExportService.shared.importListings(from: exportData, context: context, replaceExisting: false)
            
            completion(.success(importResult))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Helper Methods
    
    #if os(iOS)
    func presentShareSheet(for url: URL, from controller: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        controller.present(activityViewController, animated: true)
    }
    #endif
    
    private func createSharingURL(for share: CKShare) -> URL {
        // For demo purposes, create a custom URL that can be used by our app
        // In a real implementation, you would use share.url
        let containerIdentifier = "iCloud.fardavide.Domori"
        let recordName = share.recordID.recordName
        
        return URL(string: "https://icloud.com/\(containerIdentifier)/\(recordName)")!
    }
}

// MARK: - CloudKit URL Extension

extension CKShare {
    var url: URL {
        let containerIdentifier = "iCloud.fardavide.Domori"
        // Avoid the unused variable warning
        _ = CKContainer(identifier: containerIdentifier)
        
        return URL(string: "https://icloud.com/\(containerIdentifier)/\(self.recordID.recordName)")!
    }
} 