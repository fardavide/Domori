import Testing
import FirebaseFirestore
import Foundation
import UniformTypeIdentifiers
@testable import Domori

@MainActor
final class PropertyExportServiceTests {
  
  private let exportService = PropertyImportService.shared
  private let firestore = Firestore.createTestFirestore()
  
  // MARK: - Basic Functionality Tests
  
  @Test("Supported file types")
  func supportedFileTypes() {
    print("🔍 Testing supported file types")
    let supportedTypes = PropertyImportService.supportedFileTypes
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
  
  // MARK: - Import Tests
  
  @Test("Import data")
  func importData() async throws {
    print("🧪 Testing import data")
    
    let data = """
      {
        "properties": [
          {
            "title": "Arenella huge garden",
            "location": "Arenella",
            "link": "C.it",
            "agentContact": "123987",
            "price": 248000,
            "size": 170,
            "bedrooms": 4,
            "bathrooms": 2.5,
            "type": "villa",
            "rating": "excluded",
            "tagIds": []
          },
          {
            "title": "FBA Swimming Pool",
            "location": "Fontane Bianche",
            "link": "https://www.immobiliare.it/en/annunci/120347622/",
            "agentContact": "+39 339 4933299",
            "price": 250000,
            "size": 205,
            "bedrooms": 5,
            "bathrooms": 2,
            "type": "villa",
            "rating": "excluded",
            "tagIds": []
          },
          {
            "title": "Meomartini 2020",
            "location": "Arenella, Isole della Sonda 43",
            "link": "https://www.immobiliare.it/en/annunci/120121380/",
            "agentContact": "",
            "price": 249000,
            "size": 107,
            "bedrooms": 2,
            "bathrooms": 2,
            "type": "villa",
            "rating": "good",
            "tagIds": []
          },
          {
            "title": "Plemmirio Yellow",
            "location": "Plemmirio, via Mallia",
            "link": "https://www.immobiliare.it/en/annunci/120291050/",
            "agentContact": "Marco Millecase 320 6332111",
            "price": 258000,
            "size": 165,
            "bedrooms": 4,
            "bathrooms": 2,
            "type": "villa",
            "rating": "good",
            "tagIds": []
          }
        ],
        "tags": [
          {
            "name": "Status",
            "rating": "considering"
          },
          {
            "name": "Price",
            "rating": "good"
          },
          {
            "name": "Electric system",
            "rating": "considering"
          },
          {
            "name": "1st floor not regular",
            "rating": "excluded"
          },
          {
            "name": "From 70'",
            "rating": "considering"
          },
          {
            "name": "Sea distance",
            "rating": "good"
          },
          {
            "name": "Outdoor stairs",
            "rating": "considering"
          },
          {
            "name": "Garden",
            "rating": "good"
          },
          {
            "name": "State",
            "rating": "excluded"
          },
          {
            "name": "Size",
            "rating": "considering"
          },
          {
            "name": "New",
            "rating": "excellent"
          }
        ]
      } 

      """
      .data(using: .utf8)!
    
    let result = try exportService.importListings(
      from: data,
      firestore: firestore
    )
    
    print("📋 Import result: success=\(result.success), imported=\(result.importedCount)")
    #expect(result.success, "Import of data should succeed")
    #expect(result.importedCount == 4, "Should import 4 properties from data")
    print("✅ Import data passed")
  }
}
