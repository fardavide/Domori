import Testing
import AppIntents
import FirebaseFirestore
import Foundation
@testable import Domori

@MainActor
final class ImportPropertyIntentTests {
  
  @Test("Import property intent returns correct value type")
  func testImportPropertyIntentReturnsValue() async throws {
    let intent = ImportPropertyIntent()
    intent.jsonPayload = """
        {
          "title": "Test Property",
          "location": "123 Test Street",
          "link": "https://example.com/test",
          "agentContact": "test@example.com",
          "price": 500000,
          "size": 100,
          "bedrooms": 2,
          "bathrooms": 1.5,
          "type": "house"
        }
        """
    intent.openEditor = false
    
    let result = try await intent.perform()
    let value = try result.value
    #expect(value == "Property imported successfully")
  }
  
  @Test("Import property intent with openEditor returns correct value")
  func testImportPropertyIntentWithOpenEditor() async throws {
    let intent = ImportPropertyIntent()
    intent.jsonPayload = """
        {
          "title": "Test Property",
          "location": "123 Test Street",
          "link": "https://example.com/test",
          "agentContact": "test@example.com",
          "price": 500000,
          "size": 100,
          "bedrooms": 2,
          "bathrooms": 1.5,
          "type": "house"
        }
        """
    intent.openEditor = true
    
    let result = try await intent.perform()
    let value = try result.value
    #expect(value == "Opening Domori with imported property data")
  }
  
  @Test("Import property intent handles invalid JSON")
  func testImportPropertyIntentHandlesInvalidJson() async {
    let intent = ImportPropertyIntent()
    intent.jsonPayload = "{ invalid json }"
    intent.openEditor = false
    
    do {
      _ = try await intent.perform()
      #expect(Bool(false), "Should have thrown an error")
    } catch {
      #expect(error.localizedDescription.contains("Parsing failed"))
    }
  }
  
  @Test("Import property intent with missing fields uses defaults")
  func testImportPropertyIntentWithMissingFields() async throws {
    let intent = ImportPropertyIntent()
    intent.jsonPayload = """
        {
          "title": "Test Property",
          "link": "https://example.com/test"
        }
        """
    intent.openEditor = false
    
    let result = try await intent.perform()
    let value = result.value
    #expect(value == "Property imported successfully")
  }
} 
