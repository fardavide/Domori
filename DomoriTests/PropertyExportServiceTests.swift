import Testing
import FirebaseFirestore
import Foundation
import UniformTypeIdentifiers
@testable import Domori

@MainActor
final class PropertyExportServiceTests {
  
  private let exportService = PropertyExportService.shared
  private let firestore = Firestore.createTestFirestore()
  
  // MARK: - Basic Functionality Tests
  
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
    
    // Create test data that matches ExportData format
    let testExport = ExportData(properties: [], tags: [])
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let testData = try encoder.encode(testExport)
    
    print("🔍 Validating data of size: \(testData.count) bytes")
    let result = exportService.validateImportData(testData)
    
    print("📋 Validation result - isValid: \(result.isValid), count: \(result.listingCount)")
    #expect(result.isValid, "Valid JSON data should pass validation")
    #expect(result.listingCount == 0, "Empty export should have 0 properties")
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
  func exportEmptyListings() async throws {
    print("🧪 Testing export empty listings")
    
    let data = try await exportService.exportAllListings(firestore: firestore)
    print("📋 Export data size: \(data.count) bytes")
    
    #expect(data.count > 0, "Export data should not be empty")
    
    // Validate the exported data
    let result = exportService.validateImportData(data)
    #expect(result.isValid, "Exported data should be valid")
    #expect(result.listingCount == 0, "Should export 0 properties when database is empty")
    print("✅ Empty listings export passed")
  }
  
  @Test("Export with listings")
  func exportWithListings() async throws {
    print("🧪 Testing export with listings")
    
    // Create test property
    let property = Property(
      title: "Test Property",
      location: "Test Location",
      link: "https://example.com",
      agentContact: "Test Agent",
      price: 100000,
      size: 50,
      bedrooms: 2,
      bathrooms: 1,
      type: .apartment,
      rating: .good
    )
    
    // Add to Firestore
    try firestore.collection(.properties).addDocument(from: property)
    
    let data = try await exportService.exportAllListings(firestore: firestore)
    print("📋 Export data size with 1 property: \(data.count) bytes")
    
    // Validate the exported data
    let result = exportService.validateImportData(data)
    #expect(result.isValid, "Exported data should be valid")
    #expect(result.listingCount == 1, "Should export 1 property")
    print("✅ Export with listings passed")
  }
  
  // MARK: - Import Tests
  
  @Test("Import empty data")
  func importEmptyData() async throws {
    print("🧪 Testing import empty data")
    
    // Create empty export data
    let emptyExport = ExportData(properties: [], tags: [])
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(emptyExport)
    
    let result = exportService.importListings(
      from: data,
      firestore: firestore
    )
    
    print("📋 Import result: success=\(result.success), imported=\(result.importedCount)")
    #expect(result.success, "Import of empty data should succeed")
    #expect(result.importedCount == 0, "Should import 0 properties from empty data")
    print("✅ Import empty data passed")
  }
}
