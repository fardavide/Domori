import XCTest
import FirebaseCore
import FirebaseFirestore
@testable import Domori

final class DatabaseSharingTests: XCTestCase {
  
  let firestore = Firestore.createTestFirestore()
  
  @MainActor override func setUpWithError() throws {
    // Add some sample data
    let sampleProperty = Property(
      title: "Test Property",
      location: "Test Location",
      link: "https://example.com",
      agentContact: "test@example.com",
      price: 500000,
      size: 120,
      bedrooms: 3,
      bathrooms: 2,
      type: .house,
      rating: .good
    )
    
    try firestore.collection(.properties).addDocument(from: sampleProperty)
  }
  
  @MainActor
  func testExportAllListings() async throws {
    // Test that PropertyExportService can export all listings
    let exportData = try await PropertyExportService.shared.exportAllListings(firestore: firestore)
    
    // Verify the exported data is valid JSON
    XCTAssertNoThrow(try JSONSerialization.jsonObject(with: exportData, options: []))
    
    // Decode the data to verify structure
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    let exportedData = try decoder.decode(ExportData.self, from: exportData)
    XCTAssertEqual(exportedData.properties.count, 1)
    XCTAssertEqual(exportedData.properties.first?.title, "Test Property")
  }
  
  @MainActor
  func testImportListings() async throws {
    // First, export some data
    let exportData = try await PropertyExportService.shared.exportAllListings(firestore: firestore)
    
    // Create a new Firestore instance for import testing
    let importFirestore = try await Firestore.createTestFirestore()
    
    // Import the data
    let importResult = PropertyExportService.shared.importListings(
      from: exportData,
      firestore: importFirestore
    )
    
    // Verify import was successful
    XCTAssertTrue(importResult.success)
    XCTAssertEqual(importResult.importedCount, 1)
    XCTAssertEqual(importResult.skippedCount, 0)
    
    // Fetch the imported property
    let importedSnapshot = try await importFirestore.collection(.properties).getDocuments()
    let importedProperties = importedSnapshot.documents.compactMap { try? $0.data(as: Property.self) }
    
    XCTAssertEqual(importedProperties.count, 1)
    XCTAssertEqual(importedProperties.first?.title, "Test Property")
  }
  
  @MainActor
  func testFirestoreTestEnvironment() {
    // Test that our Firestore test environment is properly configured
    XCTAssertNotNil(firestore, "Firestore should be initialized")
    
    // Test that we can access the test collections
    let propertiesCollection = firestore.collection(.properties)
    let tagsCollection = firestore.collection(.tags)
    
    XCTAssertNotNil(propertiesCollection, "Properties collection should be accessible")
    XCTAssertNotNil(tagsCollection, "Tags collection should be accessible")
  }
}
