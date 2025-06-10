import Testing
import SwiftData
import Foundation
import UniformTypeIdentifiers
@testable import Domori

@MainActor
final class PropertyExportServiceTests {
    
    var container: ModelContainer!
    var context: ModelContext!
    private let exportService = PropertyExportService.shared
    
    init() throws {
        // Create in-memory container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: PropertyListing.self, PropertyTag.self, configurations: config)
        context = container.mainContext
    }
    
    deinit {
        container = nil
        context = nil
    }
    
    // MARK: - Basic Functionality Tests
    
    @Test("Container setup works")
    func containerSetupWorks() throws {
        print("🧪 Testing container setup")
        #expect(container != nil, "Container should be initialized")
        #expect(context != nil, "Context should be initialized")
        print("✅ Container setup works")
    }
    
    @Test("Supported file types")
    func supportedFileTypes() {
        print("🔍 Testing supported file types")
        let supportedTypes = PropertyExportService.supportedFileTypes
        print("📋 Supported types: \(supportedTypes)")
        
        #expect(supportedTypes.contains(UTType.json), "Should support JSON files")
    }
    
    @Test("Validate valid data")
    func validateValidData() throws {
        print("🧪 Testing validate valid data")
        
        // Create test data that matches PropertyListingsExport format
        let testExport = PropertyListingsExport(listings: [])
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let testData = try encoder.encode(testExport)
        
        print("🔍 Validating data of size: \(testData.count) bytes")
        let result = exportService.validateImportData(testData)
        
        print("📋 Validation result - isValid: \(result.isValid), count: \(result.listingCount)")
        #expect(result.isValid, "Valid JSON data should pass validation")
        #expect(result.listingCount == 0, "Empty export should have 0 listings")
        #expect(result.version == "1.0", "Version should be 1.0")
        print("✅ Valid data validation passed")
    }
    
    @Test("Validate invalid data")
    func validateInvalidData() throws {
        print("🧪 Testing validate invalid data")
        let invalidData = "invalid json".data(using: .utf8)!
        
        let result = exportService.validateImportData(invalidData)
        
        print("📋 Invalid data validation result: \(result.isValid)")
        #expect(!result.isValid, "Invalid JSON should fail validation")
        #expect(result.error != nil, "Should have error message for invalid data")
        print("✅ Invalid data validation failed as expected")
    }
    
    // MARK: - Export Tests
    
    @Test("Export empty listings")
    func exportEmptyListings() throws {
        print("🧪 Testing export empty listings")
        
        let data = try exportService.exportAllListings(context: context)
        print("📋 Export data size: \(data.count) bytes")
        
        #expect(data.count > 0, "Export data should not be empty")
        
        // Validate the exported data
        let result = exportService.validateImportData(data)
        #expect(result.isValid, "Exported data should be valid")
        #expect(result.listingCount == 0, "Should export 0 listings when database is empty")
        print("✅ Empty listings export passed")
    }
    
    @Test("Export with listings")
    func exportWithListings() throws {
        print("🧪 Testing export with listings")
        
        // Create test property listing
        let property = PropertyListing(
            title: "Test Property",
            location: "Test Location",
            link: "https://example.com",
            agentContact: "Test Agent",
            price: 100000,
            size: 50,
            bedrooms: 2,
            bathrooms: 1,
            propertyType: .apartment,
            propertyRating: .good
        )
        context.insert(property)
        
        try context.save()
        
        let data = try exportService.exportAllListings(context: context)
        print("📋 Export data size with 1 property: \(data.count) bytes")
        
        // Validate the exported data
        let result = exportService.validateImportData(data)
        #expect(result.isValid, "Exported data should be valid")
        #expect(result.listingCount == 1, "Should export 1 listing")
        print("✅ Export with listings passed")
    }
    
    // MARK: - Import Tests
    
    @Test("Import empty data")
    func importEmptyData() throws {
        print("🧪 Testing import empty data")
        
        // Create empty export data
        let emptyExport = PropertyListingsExport(listings: [])
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(emptyExport)
        
        let result = exportService.importListings(
            from: data,
            context: context,
            replaceExisting: false
        )
        
        print("📋 Import result: success=\(result.success), imported=\(result.importedCount)")
        #expect(result.success, "Import of empty data should succeed")
        #expect(result.importedCount == 0, "Should import 0 properties from empty data")
        print("✅ Import empty data passed")
    }
    
    @Test("Round-trip export/import")
    func roundTripExportImport() throws {
        print("🧪 Testing round-trip export/import")
        
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
            propertyRating: .excellent
        )
        context.insert(originalProperty)
        
        try context.save()
        
        // Export all properties
        let exportData = try exportService.exportAllListings(context: context)
        print("📋 Exported data size: \(exportData.count) bytes")
        
        // Clear the database
        let allProperties = try context.fetch(FetchDescriptor<PropertyListing>())
        for property in allProperties {
            context.delete(property)
        }
        try context.save()
        
        // Verify database is empty
        let emptyCheck = try context.fetch(FetchDescriptor<PropertyListing>())
        #expect(emptyCheck.isEmpty, "Database should be empty after clearing")
        
        // Import the data back
        let importResult = exportService.importListings(
            from: exportData,
            context: context,
            replaceExisting: false
        )
        
        print("📋 Import result: success=\(importResult.success), imported=\(importResult.importedCount)")
        #expect(importResult.success, "Import should succeed")
        #expect(importResult.importedCount == 1, "Should import 1 property")
        
        // Verify the imported property
        let importedProperties = try context.fetch(FetchDescriptor<PropertyListing>())
        #expect(importedProperties.count == 1, "Should have 1 imported property")
        
        let importedProperty = importedProperties.first!
        #expect(importedProperty.title == originalProperty.title, "Title should match")
        #expect(importedProperty.location == originalProperty.location, "Location should match")
        #expect(importedProperty.price == originalProperty.price, "Price should match")
        #expect(importedProperty.propertyType == originalProperty.propertyType, "Property type should match")
        #expect(importedProperty.propertyRating == originalProperty.propertyRating, "Rating should match")
        
        print("✅ Round-trip export/import passed")
    }
    
    @Test("Import with replace existing")
    func importWithReplaceExisting() throws {
        print("🧪 Testing import with replace existing")
        
        // Create initial property
        let initialProperty = PropertyListing(
            title: "Initial Property",
            location: "Initial Location",
            link: "https://initial.com",
            agentContact: nil,
            price: 150000,
            size: 60,
            bedrooms: 2,
            bathrooms: 1,
            propertyType: .apartment,
            propertyRating: .good
        )
        context.insert(initialProperty)
        try context.save()
        
        // Create import data with different property
        let importProperty = PropertyListing(
            title: "Import Property",
            location: "Import Location",
            link: "https://import.com",
            agentContact: "Import Agent",
            price: 250000,
            size: 80,
            bedrooms: 3,
            bathrooms: 2,
            propertyType: .house,
            propertyRating: .excellent
        )
        
        let exportData = PropertyListingsExport(listings: [importProperty])
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(exportData)
        
        // Import with replace existing
        let result = exportService.importListings(
            from: data,
            context: context,
            replaceExisting: true
        )
        
        print("📋 Import result: success=\(result.success), imported=\(result.importedCount)")
        #expect(result.success, "Import should succeed")
        #expect(result.importedCount == 1, "Should import 1 property")
        
        // Verify only the imported property exists
        let allProperties = try context.fetch(FetchDescriptor<PropertyListing>())
        #expect(allProperties.count == 1, "Should have only 1 property after replace")
        
        let finalProperty = allProperties.first!
        #expect(finalProperty.title == "Import Property", "Should have the imported property")
        
        print("✅ Import with replace existing passed")
    }
}
