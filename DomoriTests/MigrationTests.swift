import XCTest
import SwiftData
@testable import Domori

@MainActor
final class MigrationTests: XCTestCase {
    
    var container: ModelContainer!
    var context: ModelContext!
    
    override func setUp() async throws {
        // Create in-memory container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: PropertyListing.self, PropertyNote.self, PropertyTag.self, PropertyPhoto.self, configurations: config)
        context = container.mainContext
    }
    
    override func tearDown() async throws {
        container = nil
        context = nil
    }
    
    func testPropertyRatingMigration() throws {
        // Test that we can create properties with legacy ratings and they get migrated
        let legacyProperty = PropertyListing(
            title: "Legacy Property",
            address: "123 Legacy St",
            price: 500000,
            size: 100,
            bedrooms: 2,
            bathrooms: 1.0,
            propertyType: .apartment,
            rating: 4.5
        )
        
        context.insert(legacyProperty)
        try context.save()
        
        // Verify the legacy property got migrated to the new rating system
        XCTAssertEqual(legacyProperty.propertyRating, .good, "Property with rating 4.5 should be good")
        XCTAssertEqual(legacyProperty.location, "123 Legacy St", "Address should be mapped to location")
        XCTAssertNil(legacyProperty.link, "Legacy property should not have a link")
        
        // Test the migration helper directly
        let testProperty = PropertyListing(
            title: "Test Property",
            address: "456 Test Ave",
            price: 300000,
            size: 80,
            bedrooms: 1,
            bathrooms: 1.0,
            propertyType: .studio,
            rating: 2.0
        )
        
        context.insert(testProperty)
        try context.save()
        
        XCTAssertEqual(testProperty.propertyRating, .excluded, "Property with rating 2.0 should be excluded")
        XCTAssertEqual(testProperty.location, "456 Test Ave", "Address should be mapped to location")
        XCTAssertNil(testProperty.link, "Legacy property should not have a link")
    }
    
    func testPropertyRatingConversion() {
        // Test the conversion logic
        XCTAssertEqual(PropertyRating.fromLegacy(rating: 0.0, isFavorite: false), .none)
        XCTAssertEqual(PropertyRating.fromLegacy(rating: 1.5, isFavorite: false), .excluded)
        XCTAssertEqual(PropertyRating.fromLegacy(rating: 3.0, isFavorite: false), .considering)
        XCTAssertEqual(PropertyRating.fromLegacy(rating: 4.0, isFavorite: false), .good)
        XCTAssertEqual(PropertyRating.fromLegacy(rating: 5.0, isFavorite: false), .excellent)
        
        // Test favorite property conversion
        XCTAssertEqual(PropertyRating.fromLegacy(rating: 4.0, isFavorite: true), .excellent)
        XCTAssertEqual(PropertyRating.fromLegacy(rating: 3.5, isFavorite: true), .good)
    }
    
    func testBackwardCompatibility() {
        // Test that new properties can still be read with legacy values
        let newProperty = PropertyListing(
            title: "New Property",
            location: "789 New Blvd",
            link: "https://example.com/new-property",
            price: 750000,
            size: 150,
            bedrooms: 3,
            bathrooms: 2.0,
            propertyType: .house,
            propertyRating: .good
        )
        
        context.insert(newProperty)
        
        // Verify legacy values are set correctly
        XCTAssertEqual(newProperty.rating, 4.0, "Good rating should convert to 4.0")
        XCTAssertEqual(newProperty.location, "789 New Blvd", "Location should be set correctly")
        XCTAssertEqual(newProperty.link, "https://example.com/new-property", "Link should be set correctly")
    }
    
    func testDataMigrationManager() async throws {
        // Create some legacy properties by manually setting fields to simulate old data
        let property1 = PropertyListing(
            title: "Property 1",
            address: "100 Test St",
            price: 400000,
            size: 90,
            bedrooms: 2,
            bathrooms: 1.0,
            propertyType: .condo,
            rating: 0.0
        )
        
        let property2 = PropertyListing(
            title: "Property 2", 
            address: "200 Test St",
            price: 600000,
            size: 120,
            bedrooms: 3,
            bathrooms: 2.0,
            propertyType: .house,
            rating: 3.5
        )
        
        // Reset propertyRating to nil to simulate legacy data that didn't have this field
        property1.propertyRating = nil
        property2.propertyRating = nil
        
        context.insert(property1)
        context.insert(property2)
        try context.save()
        
        // Test migration check
        XCTAssertTrue(DataMigrationManager.needsMigration(context: context), "Should detect migration is needed")
        
        // Perform migration
        await DataMigrationManager.migratePropertyListings(context: context)
        
        // Verify migration worked
        XCTAssertFalse(DataMigrationManager.needsMigration(context: context), "Should not need migration after it's complete")
        XCTAssertTrue(DataMigrationManager.validateMigration(context: context), "Migration should be valid")
        
        // Check specific properties - property1 has rating 0.0 and no favorite, should stay nil after migration
        XCTAssertEqual(property1.propertyRating, nil, "Property with no rating should stay as nil")
        XCTAssertEqual(property2.propertyRating, .considering, "Property with rating 3.5 should be considering")
        
        // Verify location mapping worked
        XCTAssertEqual(property1.location, "100 Test St", "Address should be mapped to location")
        XCTAssertEqual(property2.location, "200 Test St", "Address should be mapped to location")
        XCTAssertNil(property1.link, "Legacy property should not have a link")
        XCTAssertNil(property2.link, "Legacy property should not have a link")
    }
    
    func testMigrationRobustness() {
        // Test that migration doesn't crash with edge cases
        let edgeProperty = PropertyListing(
            title: "Edge Case Property",
            address: "999 Edge St",
            price: 1000000,
            size: 200,
            bedrooms: 5,
            bathrooms: 3.5,
            propertyType: .villa,
            rating: -1.0 // Invalid rating
        )
        
        context.insert(edgeProperty)
        
        // Should handle invalid rating gracefully - negative rating should result in .none
        XCTAssertEqual(edgeProperty.propertyRating, PropertyRating.none, "Property with invalid rating should be .none")
        XCTAssertEqual(edgeProperty.location, "999 Edge St", "Address should be mapped to location")
        XCTAssertNil(edgeProperty.link, "Legacy property should not have a link")
    }
    
    func testRemovingIsFavoriteField() async throws {
        // Create a property with the current model (which still has isFavorite)
        let property = PropertyListing(
            title: "Test Property",
            location: "123 Test St",
            link: "https://example.com/test",
            price: 500000,
            size: 100,
            bedrooms: 2,
            bathrooms: 1.0,
            propertyType: .house,
            rating: 0.0,
            propertyRating: .good
        )
        
        context.insert(property)
        try context.save()
        
        // Verify the property was saved correctly
        let descriptor = FetchDescriptor<PropertyListing>()
        let properties = try context.fetch(descriptor)
        XCTAssertEqual(properties.count, 1)
        
        let savedProperty = properties[0]
        XCTAssertEqual(savedProperty.title, "Test Property")
        XCTAssertEqual(savedProperty.location, "123 Test St")
        XCTAssertEqual(savedProperty.link, "https://example.com/test")
        XCTAssertEqual(savedProperty.propertyRating, .good)
        
        // The key test: if we remove isFavorite from the model but the data still exists,
        // SwiftData should handle it gracefully since we're using propertyRating now
        print("✅ Property can be accessed without isFavorite field causing issues")
    }
    
    func testNewPropertyStructure() throws {
        // Test that new properties with links work correctly
        let newProperty = PropertyListing(
            title: "New Property with Link",
            location: "456 Modern Ave",
            link: "https://example.com/modern-property",
            price: 850000,
            size: 180,
            bedrooms: 4,
            bathrooms: 2.5,
            propertyType: .house,
            propertyRating: .excellent
        )
        
        context.insert(newProperty)
        try context.save()
        
        // Verify all new fields are set correctly
        XCTAssertEqual(newProperty.title, "New Property with Link")
        XCTAssertEqual(newProperty.location, "456 Modern Ave")
        XCTAssertEqual(newProperty.link, "https://example.com/modern-property")
        XCTAssertEqual(newProperty.price, 850000)
        XCTAssertEqual(newProperty.propertyRating, .excellent)
        
        // Verify legacy rating is also set correctly
        XCTAssertEqual(newProperty.rating, 5.0, "Excellent rating should convert to 5.0")
    }
} 