import Testing
import AppIntents
import FirebaseAuth
import FirebaseFirestore
import Foundation
@testable import Domori

@MainActor
final class PropertyImportServiceTests {
  
  @Test("Parse and validate valid property JSON")
  func testParseAndValidateValidJson() throws {
    let scenario = Scenario()
    let jsonPayload = """
        {
          "title": "Test Property",
          "location": "123 Test Street",
          "link": "https://example.com/test",
          "agency": "Casecase",
          "price": 500000,
          "size": 100,
          "bedrooms": 2,
          "bathrooms": 1.5,
          "type": "house"
        }
        """
    let data = try scenario.sut.parseAndValidate(jsonPayload)
    #expect(data.title == "Test Property")
    #expect(data.location == "123 Test Street")
    #expect(data.link == "https://example.com/test")
    #expect(data.agency == "Casecase")
    #expect(data.price == 500000)
    #expect(data.size == 100)
    #expect(data.bedrooms == 2)
    #expect(data.bathrooms == 1.5)
    #expect(data.type == .house)
  }
  
  @Test("Parse property JSON with different case variations")
  func testParsePropertyJsonWithCaseVariations() throws {
    let scenario = Scenario()
    // Test uppercase
    let jsonPayload1 = """
        {
          "title": "Test Property",
          "location": "123 Test Street",
          "link": "https://example.com/test",
          "agentContact": "test@example.com",
          "price": 500000,
          "size": 100,
          "bedrooms": 2,
          "bathrooms": 1.5,
          "type": "APARTMENT"
        }
        """
    let data1 = try scenario.sut.parseAndValidate(jsonPayload1)
    #expect(data1.type == .apartment)
    
    // Test mixed case
    let jsonPayload2 = """
        {
          "title": "Test Property",
          "location": "123 Test Street",
          "link": "https://example.com/test",
          "agentContact": "test@example.com",
          "price": 500000,
          "size": 100,
          "bedrooms": 2,
          "bathrooms": 1.5,
          "type": "Condo"
        }
        """
    let data2 = try scenario.sut.parseAndValidate(jsonPayload2)
    #expect(data2.type == .condo)
    
    // Test lowercase
    let jsonPayload3 = """
        {
          "title": "Test Property",
          "location": "123 Test Street",
          "link": "https://example.com/test",
          "agentContact": "test@example.com",
          "price": 500000,
          "size": 100,
          "bedrooms": 2,
          "bathrooms": 1.5,
          "type": "townhouse"
        }
        """
    let data3 = try scenario.sut.parseAndValidate(jsonPayload3)
    #expect(data3.type == .townhouse)
  }
  
  @Test("Parse invalid JSON")
  func testParseInvalidJson() {
    let scenario = Scenario()
    let invalidJson = "{ invalid json }"
    do {
      _ = try scenario.sut.parseAndValidate(invalidJson)
      #expect(Bool(false), "Should have thrown an error")
    } catch {
      #expect(error.localizedDescription.contains("JSON decoding failed") || error.localizedDescription.contains("parsing failed"))
    }
  }
  
  @Test("Allows missing fields")
  func allowsMissingFields() throws {
    let scenario = Scenario()
    let emptyJson = "{}"
    _ = try scenario.sut.parseAndValidate(emptyJson)
  }
  
  @Test("Encode and decode property data for URL")
  func testEncodeDecodePropertyDataForUrl() throws {
    let scenario = Scenario()
    let testData = PropertyImportData(
      title: "Test Property",
      location: "123 Test Street",
      link: "https://example.com/test",
      agency: "test@example.com",
      price: 500000,
      size: 100,
      bedrooms: 2,
      bathrooms: 1.5,
      type: .house
    )
    let encoded = try scenario.sut.encodePropertyDataForUrl(testData)
    #expect(!encoded.isEmpty)
    let decoded = try decodePropertyDataFromUrl(encoded)
    #expect(decoded.title == testData.title)
    #expect(decoded.location == testData.location)
    #expect(decoded.link == testData.link)
    #expect(decoded.agency == testData.agency)
    #expect(decoded.price == testData.price)
    #expect(decoded.size == testData.size)
    #expect(decoded.bedrooms == testData.bedrooms)
    #expect(decoded.bathrooms == testData.bathrooms)
    #expect(decoded.type == testData.type)
  }
  
  @Test("Save property to Firestore")
  func testSavePropertyToFirestore() async throws {
    let scenario = Scenario()
    let importData = PropertyImportData(
      title: "Firestore Test",
      location: "Test Location",
      link: "https://example.com/firestore",
      agency: "",
      price: 123456,
      size: 42,
      bedrooms: 1,
      bathrooms: 1.0,
      type: .apartment
    )
    let ref = try await scenario.sut.saveProperty(importData)
    var property = Property(
      title: "Firestore Test",
      location: "Test Location",
      link: "https://example.com/firestore",
      agency: "",
      price: 123456,
      size: 42,
      bedrooms: 1,
      bathrooms: 1.0,
      type: .apartment
    )
    let savedProperty = try await ref.getDocument(as: Property.self)
    property.id = savedProperty.id
    property.createdDate = savedProperty.createdDate
    property.updatedDate = savedProperty.updatedDate
    property.userIds = [scenario.user.uid]
    #expect(savedProperty == property)
  }
  
  private struct Scenario {
    let sut: PropertyImportService
    let user = User.sampleEmail
    
    init() {
      let userQuery = UserQuery(authService: .fake(currentUser: user))
      sut = PropertyImportService(
        propertyQuery: .init(
          userQuery: userQuery,
          workspaceQuery: .fake(workspace: .sample(forUserId: user.uid))
        )
      )
    }
  }
}

private func decodePropertyDataFromUrl(_ encodedData: String) throws -> PropertyImportData {
  guard let data = Data(base64Encoded: encodedData) else {
    throw ImportError.invalidJsonEncoding
  }
  let decoder = JSONDecoder()
  return try decoder.decode(PropertyImportData.self, from: data)
}
