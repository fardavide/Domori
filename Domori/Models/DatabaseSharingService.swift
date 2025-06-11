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
    case invalidRecordValue(String)
    
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
        case .invalidRecordValue(let message):
            return "Invalid record value: \(message)"
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
        
        // Check schema on initialization - delay to avoid conflicts with SwiftData initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            Task { @MainActor in
                try? await self.checkAndPrepareSchema()
            }
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
                "DomoriDatabaseExport": ["exportData", "exportDate", "recordTypeName", "name", "version"],
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
                            try safeSetValue(Date(), forKey: field, on: sampleRecord)
                        } else if field == "version" {
                            try safeSetValue(1, forKey: field, on: sampleRecord)
                        } else if field == "exportData" {
                            // Create a temporary file for testing
                            let tempDir = FileManager.default.temporaryDirectory
                            let fileURL = tempDir.appendingPathComponent("schema_test_\(UUID().uuidString).txt")
                            try "Schema test".write(to: fileURL, atomically: true, encoding: .utf8)
                            try safeSetValue(CKAsset(fileURL: fileURL), forKey: field, on: sampleRecord)
                        } else {
                            try safeSetValue("Schema test", forKey: field, on: sampleRecord)
                        }
                    }
                }
                
                // Try to save the record to test schema compatibility
                do {
                    let _ = try await database.save(sampleRecord)
                    print("Schema for \(recordType) created successfully")
                    
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
    
    // MARK: - Safe Record Value Setting
    
    /// Safely sets a value on a CKRecord, validating that it's a proper CKRecordValue
    private func safeSetValue(_ value: Any?, forKey key: String, on record: CKRecord) throws {
        // Check if we're trying to use a reserved key
        let reservedKeys = ["recordType", "recordID", "creationDate", "creatorUserRecordID", "lastModifiedUserRecordID", "modificationDate"]
        if reservedKeys.contains(key) {
            throw SharingError.invalidRecordValue("\(key) is a reserved key and cannot be used")
        }
        
        guard let value = value else {
            // If nil, remove the key
            record[key] = nil
            return
        }
        
        // Check if the value is a valid CKRecordValue
        if let assetValue = value as? CKAsset {
            // Ensure the file exists for CKAsset
            guard let fileURL = assetValue.fileURL, FileManager.default.fileExists(atPath: fileURL.path) else {
                throw SharingError.invalidRecordValue("Asset file does not exist")
            }
            record[key] = assetValue
        } else if let stringValue = value as? String {
            record[key] = stringValue as CKRecordValue
        } else if let numberValue = value as? NSNumber {
            record[key] = numberValue
        } else if let dateValue = value as? Date {
            record[key] = dateValue as CKRecordValue
        } else if let dataValue = value as? Data {
            record[key] = dataValue as CKRecordValue
        } else if let locationValue = value as? CLLocation {
            record[key] = locationValue
        } else if let refValue = value as? CKRecord.Reference {
            record[key] = refValue
        } else if let arrayValue = value as? [CKRecordValue] {
            record[key] = arrayValue as CKRecordValue
        } else {
            // Convert to a string as a last resort
            record[key] = String(describing: value) as CKRecordValue
        }
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
        do {
            // Create a basic record with minimum fields
            let rootRecord = CKRecord(recordType: "SharedDomoriDatabase")
            try safeSetValue("Domori Property Database", forKey: "name", on: rootRecord)
            try safeSetValue(1, forKey: "version", on: rootRecord)
            
            // Create a share for this record
            let shareRecord = CKShare(rootRecord: rootRecord)
            try safeSetValue("Domori Property Database", forKey: CKShare.SystemFieldKey.title, on: shareRecord)
            try safeSetValue("fardavide.Domori.database", forKey: CKShare.SystemFieldKey.shareType, on: shareRecord)
            
            // Save both the root record and share in the same operation
            let operation = CKModifyRecordsOperation(recordsToSave: [rootRecord, shareRecord])
            operation.savePolicy = .changedKeys
            operation.qualityOfService = .userInitiated
            
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
        } catch {
            completion(.failure(error))
        }
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
            
            // Create a temporary file URL
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("domori_export_\(UUID().uuidString).json")
            
            try exportData.write(to: fileURL)
            
            do {
                // Use a safer approach with the default record type
                let databaseRecord = CKRecord(recordType: "CKRecord")
                
                // Create a CKAsset with the export data
                let asset = CKAsset(fileURL: fileURL)
                try safeSetValue(asset, forKey: "asset", on: databaseRecord)
                try safeSetValue(Date(), forKey: "date", on: databaseRecord)
                try safeSetValue("Domori Property Database Export", forKey: "description", on: databaseRecord)
                
                // Create a share for this record
                let share = CKShare(rootRecord: databaseRecord)
                try safeSetValue("Domori Property Database", forKey: CKShare.SystemFieldKey.title, on: share)
                
                // Create an operation to save both the record and share
                let operation = CKModifyRecordsOperation(recordsToSave: [databaseRecord, share])
                operation.savePolicy = .changedKeys
                operation.qualityOfService = .userInitiated
                
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
            } catch {
                // Delete the temporary file
                try? FileManager.default.removeItem(at: fileURL)
                completion(.failure(error))
            }
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
            
            do {
                // Create a record with a default type and minimal fields
                let defaultRecord = CKRecord(recordType: "CKRecord")  // The most basic record type
                
                // Use only standard fields with proper validation
                let asset = CKAsset(fileURL: fileURL)
                try safeSetValue(asset, forKey: "asset", on: defaultRecord)
                try safeSetValue(Date(), forKey: "date", on: defaultRecord)
                try safeSetValue("Domori Property Database Export", forKey: "description", on: defaultRecord)
                
                // Create a share for this record
                let share = CKShare(rootRecord: defaultRecord)
                try safeSetValue("Domori Property Database", forKey: CKShare.SystemFieldKey.title, on: share)
                
                // Create an operation to save both the record and share
                let operation = CKModifyRecordsOperation(recordsToSave: [defaultRecord, share])
                operation.savePolicy = .changedKeys
                operation.qualityOfService = .userInitiated
                
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
                // Delete the temporary file
                try? FileManager.default.removeItem(at: fileURL)
                completion(.failure(error))
            }
        } catch {
            print("Error in fallback export: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    // MARK: - Accepting Shares
    
    @MainActor
    func acceptShare(from url: URL, context: ModelContext, completion: @escaping (Result<ImportResult, Error>) -> Void) {
        guard isCloudKitAvailable else {
            completion(.failure(SharingError.cloudKitNotAvailable))
            return
        }
        
#if targetEnvironment(simulator)
        // For simulator testing, use mock data
        print("CloudKit sharing operations are simulated in the simulator")
        createMockSharedDataForSimulator(context: context, completion: completion)
#else
        // For non-simulator devices, use direct record fetching approach
        // Since we can't easily get CKShareMetadata, we'll extract the record ID from the URL
        // and try to fetch the record directly
        extractRecordIDFromURL(url) { result in
            switch result {
            case .success(let recordID):
                self.fetchRecordAndProcess(recordID: recordID, context: context, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
#endif
    }
    
    private func extractRecordIDFromURL(_ url: URL, completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {
        // Check if we have a CloudKit sharing URL
        if url.scheme == "cloudkit-icloud.fardavide.Domori" || url.absoluteString.contains("icloud.com") {
            // Try to get the share identifier from the URL
            if let recordName = url.pathComponents.last {
                // Create a CloudKit record ID
                let recordID = CKRecord.ID(recordName: recordName)
                completion(.success(recordID))
            } else {
                completion(.failure(SharingError.sharingSetupFailed))
            }
        } else {
            completion(.failure(SharingError.sharingSetupFailed))
        }
    }
    
    @MainActor
    private func fetchRecordAndProcess(recordID: CKRecord.ID, context: ModelContext, completion: @escaping (Result<ImportResult, Error>) -> Void) {
        // Determine which database to use
        let sharedDatabase = container.sharedCloudDatabase
        
        // Create a record fetch operation
        let fetchRecordOperation = CKFetchRecordsOperation(recordIDs: [recordID])
        fetchRecordOperation.qualityOfService = .userInitiated
        
        fetchRecordOperation.perRecordResultBlock = { recordID, result in
            switch result {
            case .success(let record):
                print("Successfully fetched shared record: \(record.recordID.recordName)")
            case .failure(let error):
                print("Error fetching record \(recordID.recordName): \(error.localizedDescription)")
            }
        }
        
        // Using the older style completion handler since the newer one has different parameters
        fetchRecordOperation.fetchRecordsCompletionBlock = { recordsByID, error in
            Task { @MainActor in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let recordsByID = recordsByID else {
                    completion(.failure(SharingError.recordNotFound))
                    return
                }
                
                if let sharedRecord = recordsByID[recordID] {
                    // Process the shared record
                    self.processSharedRecord(sharedRecord, context: context, completion: completion)
                } else {
                    completion(.failure(SharingError.recordNotFound))
                }
            }
        }
        
        sharedDatabase.add(fetchRecordOperation)
    }
    
    @MainActor
    private func processSharedRecord(_ record: CKRecord, context: ModelContext, completion: @escaping (Result<ImportResult, Error>) -> Void) {
        do {
            // Get the shared data from the record
            if let asset = record["asset"] as? CKAsset, let fileURL = asset.fileURL {
                // Read the data from the file
                let data = try Data(contentsOf: fileURL)
                
                // Import the data
                let importResult = PropertyExportService.shared.importListings(from: data, context: context, replaceExisting: false)
                completion(.success(importResult))
            } else {
                // If no asset is found, look for individual property fields
                let properties = try extractPropertiesFromRecord(record)
                if !properties.isEmpty {
                    var importedCount = 0
                    var errors: [String] = []
                    
                    for property in properties {
                        context.insert(property)
                        importedCount += 1
                    }
                    
                    try context.save()
                    
                    let result = ImportResult(
                        success: true,
                        importedCount: importedCount,
                        skippedCount: 0,
                        errors: errors,
                        message: "Successfully imported \(importedCount) properties from shared record"
                    )
                    completion(.success(result))
                } else {
                    completion(.failure(SharingError.recordNotFound))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    private func extractPropertiesFromRecord(_ record: CKRecord) throws -> [PropertyListing] {
        var properties: [PropertyListing] = []
        
        // If this is a single property record
        if let title = record["title"] as? String,
           let location = record["location"] as? String,
           let link = record["link"] as? String {
            
            let price = record["price"] as? Double ?? 0
            let size = record["size"] as? Double ?? 0
            let bedrooms = record["bedrooms"] as? Int ?? 0
            let bathrooms = record["bathrooms"] as? Double ?? 0
            
            let propertyTypeString = record["propertyType"] as? String ?? "other"
            let propertyType = PropertyType(rawValue: propertyTypeString) ?? .other
            
            let propertyRatingString = record["propertyRating"] as? String ?? "none"
            let propertyRating = PropertyRating(rawValue: propertyRatingString) ?? .none
            
            let property = PropertyListing(
                title: title,
                location: location,
                link: link,
                agentContact: record["agentContact"] as? String,
                price: price,
                size: size,
                bedrooms: bedrooms,
                bathrooms: bathrooms,
                propertyType: propertyType,
                propertyRating: propertyRating
            )
            
            properties.append(property)
        }
        
        return properties
    }
    
    @MainActor
    private func createMockSharedDataForSimulator(context: ModelContext, completion: @escaping (Result<ImportResult, Error>) -> Void) {
        print("⚠️ SIMULATOR MODE: Creating mock shared data for testing purposes")
        
        do {
            // Create some sample export data for simulator testing only
            let sampleProperty = PropertyListing(
                title: "SHARED Property via CloudKit",
                location: "Shared from another device",
                link: "https://example.com/shared-property",
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
            let container = try ModelContainer(for: schema, configurations: [configuration])
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
