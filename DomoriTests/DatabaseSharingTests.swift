import XCTest
import SwiftData
@testable import Domori

final class DatabaseSharingTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    @MainActor override func setUpWithError() throws {
        // Set up in-memory SwiftData container for testing
        let schema = Schema([PropertyListing.self, PropertyTag.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = modelContainer.mainContext
        
        // Add some sample data
        let sampleProperty = PropertyListing(
            title: "Test Property",
            location: "Test Location",
            link: "https://example.com",
            agentContact: "test@example.com",
            price: 500000,
            size: 120,
            bedrooms: 3,
            bathrooms: 2,
            propertyType: .house,
            propertyRating: .good
        )
        
        modelContext.insert(sampleProperty)
    }
    
    @MainActor override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
    }
    
    @MainActor
    func testExportAllListings() throws {
        // Test that PropertyExportService can export all listings
        let exportData = try PropertyExportService.shared.exportAllListings(context: modelContext)
        
        // Verify the exported data is valid JSON
        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: exportData, options: []))
        
        // Decode the data to verify structure
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let exportedListings = try decoder.decode(PropertyListingsExport.self, from: exportData)
        XCTAssertEqual(exportedListings.listings.count, 1)
        XCTAssertEqual(exportedListings.listings.first?.title, "Test Property")
    }
    
    @MainActor
    func testImportListings() throws {
        // First, export some data
        let exportData = try PropertyExportService.shared.exportAllListings(context: modelContext)
        
        // Create a new context for import testing
        let importSchema = Schema([PropertyListing.self, PropertyTag.self])
        let importConfig = ModelConfiguration(schema: importSchema, isStoredInMemoryOnly: true)
        let importContainer = try ModelContainer(for: importSchema, configurations: [importConfig])
        let importContext = importContainer.mainContext
        
        // Import the data
        let importResult = PropertyExportService.shared.importListings(
            from: exportData,
            context: importContext,
            replaceExisting: false
        )
        
        // Verify import was successful
        XCTAssertTrue(importResult.success)
        XCTAssertEqual(importResult.importedCount, 1)
        XCTAssertEqual(importResult.skippedCount, 0)
        
        // Fetch the imported property
        let descriptor = FetchDescriptor<PropertyListing>()
        let importedProperties = try importContext.fetch(descriptor)
        
        XCTAssertEqual(importedProperties.count, 1)
        XCTAssertEqual(importedProperties.first?.title, "Test Property")
    }
    
    func testDatabaseSharingServiceCloudKitAvailability() {
        // Ensure isCloudKitAvailable works correctly in test environment
        let isAvailable = DatabaseSharingService.shared.isCloudKitAvailable
        
        #if targetEnvironment(simulator)
        XCTAssertTrue(isAvailable, "CloudKit should be considered available in the simulator")
        #else
        // This could be true or false depending on the device's iCloud status
        // Just log it for information
        print("CloudKit availability on device: \(isAvailable)")
        #endif
    }
} 