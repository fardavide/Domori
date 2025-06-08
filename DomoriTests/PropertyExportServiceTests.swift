import XCTest
import SwiftData
import Foundation
import UniformTypeIdentifiers
@testable import Domori

@MainActor
final class PropertyExportServiceTests: XCTestCase {
    
    var container: ModelContainer!
    var context: ModelContext!
    private let exportService = PropertyExportService.shared
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create in-memory container for testing
        let config = ModelConfiguration(
            isStoredInMemoryOnly: true,
            allowsSave: false,
            groupContainer: .none,
            cloudKitDatabase: .none
        )
        container = try ModelContainer(for: PropertyListing.self, SharedWorkspace.self, User.self, configurations: config)
        context = container.mainContext
    }
    
    override func tearDownWithError() throws {
        container = nil
        context = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Basic Functionality Tests
    
    func testExportServiceExists() throws {
        print("🧪 Testing export service exists")
        XCTAssertNotNil(exportService, "PropertyExportService.shared should exist")
        print("✅ Export service exists")
    }
    
    func testSupportedFileTypes() {
        print("🔍 Testing supported file types")
        let supportedTypes = PropertyExportService.supportedFileTypes
        print("📋 Supported types: \(supportedTypes)")
        
        XCTAssertTrue(supportedTypes.contains(UTType.json), "Should support JSON files")
    }
    
    func testValidateValidData() throws {
        print("🧪 Testing validate valid data")
        
        // Create test data that matches PropertyListingsExport format
        let testExport = PropertyListingsExport(listings: [])
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let testData = try encoder.encode(testExport)
        
        print("🔍 Validating data of size: \(testData.count) bytes")
        let result = exportService.validateImportData(testData)
        
        print("📋 Validation result - isValid: \(result.isValid), count: \(result.listingCount)")
        XCTAssertTrue(result.isValid, "Valid JSON data should pass validation")
        XCTAssertEqual(result.listingCount, 0, "Empty export should have 0 listings")
        XCTAssertEqual(result.version, "1.0", "Version should be 1.0")
        print("✅ Valid data validation passed")
    }
    
    func testValidateInvalidData() throws {
        print("🧪 Testing validate invalid data")
        let invalidData = "invalid json".data(using: .utf8)!
        
        let result = exportService.validateImportData(invalidData)
        
        print("📋 Invalid data validation result: \(result.isValid)")
        XCTAssertFalse(result.isValid, "Invalid JSON should fail validation")
        XCTAssertNotNil(result.error, "Should have error message for invalid data")
        print("✅ Invalid data validation failed as expected")
    }
    
    // MARK: - Export Tests
    
    func testExportEmptyListings() throws {
        print("🧪 Testing export empty listings")
        
        let data = try exportService.exportAllListings(context: context)
        print("📋 Export data size: \(data.count) bytes")
        
        XCTAssertGreaterThan(data.count, 0, "Export data should not be empty")
        
        // Validate the exported data
        let result = exportService.validateImportData(data)
        XCTAssertTrue(result.isValid, "Exported data should be valid")
        XCTAssertEqual(result.listingCount, 0, "Should export 0 listings when database is empty")
        print("✅ Empty listings export passed")
    }
    
    func testExportWithListings() throws {
        print("🧪 Testing export with listings")
        
        // Create test user and workspace
        let user = User(name: "Test User", email: "test@example.com")
        context.insert(user)
        let workspace = SharedWorkspace(name: "Test Workspace", owner: user)
        context.insert(workspace)
        
        // Create test property listing
        let property = PropertyListing(
            title: "Test Property",
            location: "Test Location",
            link: nil,
            agentContact: nil,
            price: 100000,
            size: 50,
            bedrooms: 2,
            bathrooms: 1,
            propertyType: .apartment,
            rating: 4.0,
            propertyRating: .good
        )
        property.workspace = workspace
        context.insert(property)
        
        try context.save()
        
        let data = try exportService.exportAllListings(context: context)
        print("📋 Export data size with 1 property: \(data.count) bytes")
        
        // Validate the exported data
        let result = exportService.validateImportData(data)
        XCTAssertTrue(result.isValid, "Exported data should be valid")
        XCTAssertEqual(result.listingCount, 1, "Should export 1 listing")
        print("✅ Export with listings passed")
    }
    
    // MARK: - Import Tests
    
    func testImportEmptyData() throws {
        print("🧪 Testing import empty data")
        
        // Create test user and workspace
        let user = User(name: "Test User", email: "test@example.com")
        context.insert(user)
        let workspace = SharedWorkspace(name: "Test Workspace", owner: user)
        context.insert(workspace)
        
        // Create empty export data
        let emptyExport = PropertyListingsExport(listings: [])
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(emptyExport)
        
        let result = exportService.importListings(
            from: data,
            toWorkspace: workspace,
            context: context,
            replaceExisting: false
        )
        
        print("📋 Import result: success=\(result.success), imported=\(result.importedCount)")
        XCTAssertTrue(result.success, "Import of empty data should succeed")
        XCTAssertEqual(result.importedCount, 0, "Should import 0 properties from empty data")
        print("✅ Import empty data passed")
    }
    
    func testRoundTripExportImport() throws {
        print("🧪 Testing round-trip export/import")
        
        // Create test users and workspaces
        let user1 = User(name: "User 1", email: "user1@example.com")
        let user2 = User(name: "User 2", email: "user2@example.com")
        context.insert(user1)
        context.insert(user2)
        
        let workspace1 = SharedWorkspace(name: "Source Workspace", owner: user1)
        let workspace2 = SharedWorkspace(name: "Target Workspace", owner: user2)
        context.insert(workspace1)
        context.insert(workspace2)
        
        // Create test property
        let originalProperty = PropertyListing(
            title: "Round Trip Test",
            location: "Test Location",
            link: "https://example.com",
            agentContact: "Agent Test",
            price: 200000,
            size: 75,
            bedrooms: 3,
            bathrooms: 2,
            propertyType: .house,
            rating: 4.5,
            propertyRating: .excellent
        )
        originalProperty.workspace = workspace1
        context.insert(originalProperty)
        
        try context.save()
        
        // Export from workspace1
        let exportData = try exportService.exportWorkspaceListings(workspace: workspace1, context: context)
        print("📋 Exported data size: \(exportData.count) bytes")
        
        // Import to workspace2
        let importResult = exportService.importListings(
            from: exportData,
            toWorkspace: workspace2,
            context: context,
            replaceExisting: false
        )
        
        print("📋 Import result: success=\(importResult.success), imported=\(importResult.importedCount)")
        XCTAssertTrue(importResult.success, "Import should succeed: \(importResult.message)")
        XCTAssertEqual(importResult.importedCount, 1, "Should import 1 property")
        
        // Verify imported property using simpler fetch
        let allListings = try context.fetch(FetchDescriptor<PropertyListing>())
        let importedProperties = allListings.filter { $0.workspace?.id == workspace2.id }
        
        XCTAssertEqual(importedProperties.count, 1, "Should have 1 imported property")
        
        let importedProperty = importedProperties.first!
        XCTAssertEqual(importedProperty.title, originalProperty.title)
        XCTAssertEqual(importedProperty.location, originalProperty.location)
        XCTAssertEqual(importedProperty.price, originalProperty.price)
        XCTAssertEqual(importedProperty.propertyType, originalProperty.propertyType)
        
        print("✅ Round-trip export/import passed")
    }
    
    func testValidateBackupJson() throws {
        // This is the exact JSON from your backup.json file
        let jsonString = """
        {
          "exportDate": "2025-06-08T15:43:53.293393Z",
          "version": "1.0",
          "listings": [
            {
              "title": "Arenella Meomartini",
              "bedrooms": 3,
              "bathrooms": 2,
              "size": 115,
              "price": 234000,
              "tags": [
                { "name": "Price", "rating": "good" },
                { "name": "Sea distance", "rating": "good" },
                { "name": "Size", "rating": "considering" }
              ],
              "agentContact": "123987",
              "createdDate": "2025-06-08T05:33:04Z",
              "updatedDate": "2025-06-08T15:43:53.293393Z",
              "link": "C.it",
              "location": "Arenella",
              "propertyRating": "considering",
              "propertyType": "Villa",
              "rating": 3
            }
          ]
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        // Test the validation directly
        let validation = exportService.validateImportData(jsonData)
        
        // Use XCTAssert to force display of error message
        if !validation.isValid {
            if let error = validation.error {
                NSLog("❌ VALIDATION ERROR: \(error)")
                XCTFail("JSON validation failed with error: \(error)")
            } else {
                NSLog("❌ VALIDATION FAILED: No error message provided")
                XCTFail("JSON validation failed with no error message")
            }
        } else {
            NSLog("✅ Validation passed!")
            XCTAssertEqual(validation.version, "1.0")
            XCTAssertEqual(validation.listingCount, 1)
        }
    }
}