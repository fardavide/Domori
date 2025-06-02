//

import Testing
import SwiftData
import Foundation
@testable import Domori

@MainActor
struct DomoriTests {
    
    @Test func testPropertyListingCreation() async throws {
        // Create in-memory container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PropertyListing.self, PropertyTag.self, configurations: config)
        let context = container.mainContext
        
        // Create a test property
        let property = PropertyListing(
            title: "Test Property",
            location: "123 Test Street",
            link: "https://example.com/test",
            price: 500000,
            size: 100,
            bedrooms: 2,
            bathrooms: 1.5,
            propertyType: .house,
            propertyRating: .good
        )
        
        context.insert(property)
        try context.save()
        
        // Verify the property was created correctly
        #expect(property.title == "Test Property")
        #expect(property.location == "123 Test Street")
        #expect(property.link == "https://example.com/test")
        #expect(property.price == 500000)
        #expect(property.size == 100)
        #expect(property.bedrooms == 2)
        #expect(property.bathrooms == 1.5)
        #expect(property.propertyType == .house)
        #expect(property.propertyRating == .good)
        #expect(property.rating == 4.0) // Should convert to legacy rating
    }
    
    @Test func testPropertyListingWithTags() async throws {
        // Create in-memory container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PropertyListing.self, PropertyTag.self, configurations: config)
        let context = container.mainContext
        
        // Create a test property
        let property = PropertyListing(
            title: "Test Property with Tags",
            location: "456 Tag Street",
            link: "https://example.com/tags",
            price: 750000,
            size: 150,
            bedrooms: 3,
            bathrooms: 2.0,
            propertyType: .condo,
            propertyRating: .excellent
        )
        
        // Create some tags
        let tag1 = PropertyTag(name: "Great Location", color: .green)
        let tag2 = PropertyTag(name: "Needs Work", color: .red)
        
        property.tags.append(tag1)
        property.tags.append(tag2)
        
        context.insert(property)
        context.insert(tag1)
        context.insert(tag2)
        try context.save()
        
        // Verify the property and tags were created correctly
        #expect(property.tags.count == 2)
        #expect(property.tags.contains(tag1))
        #expect(property.tags.contains(tag2))
    }
    
    @Test func testPropertyTagCreation() async throws {
        // Create in-memory container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PropertyListing.self, PropertyTag.self, configurations: config)
        let context = container.mainContext
        
        // Create a test property
        let property = PropertyListing(
            title: "Test Property",
            location: "123 Test Street",
            price: 500000,
            size: 100,
            bedrooms: 2,
            bathrooms: 1.5,
            propertyType: .house,
            propertyRating: .good
        )
        
        // Test creating tags for different categories
        let tagColors = TagColor.allCases
        for color in tagColors {
            let tag = PropertyTag(name: "Test \(color.rawValue) tag", color: color)
            property.tags.append(tag)
            context.insert(tag)
        }
        
        context.insert(property)
        try context.save()
        
        #expect(property.tags.count == TagColor.allCases.count)
        
        // Verify each tag has the correct color
        let colors = TagColor.allCases
        for (index, tag) in property.tags.enumerated() {
            #expect(tag.color == colors[index])
        }
    }
    
    @Test func testPropertyRatingSystem() async throws {
        // Test all property rating values
        let ratings = PropertyRating.allCases
        
        for rating in ratings {
            let property = PropertyListing(
                title: "Test \(rating.rawValue) Property",
                location: "123 Rating Street",
                price: 500000,
                size: 100,
                bedrooms: 2,
                bathrooms: 1.5,
                propertyType: .house,
                propertyRating: rating
            )
            
            #expect(property.propertyRating == rating)
            #expect(property.rating == rating.toLegacyRating)
        }
    }
    
    @Test func testPropertyTypeSystemImages() async throws {
        // Test that all property types have unique system images
        let types = PropertyType.allCases
        let images = Set(types.map { $0.systemImage })
        
        #expect(images.count == PropertyType.allCases.count)
    }
    
    @Test func testPropertyFormattedValues() async throws {
        let property = PropertyListing(
            title: "Test Formatting",
            location: "123 Format Street",
            price: 1234567,
            size: 150.5,
            bedrooms: 3,
            bathrooms: 2.5,
            propertyType: .house,
            propertyRating: .good
        )
        
        // Test formatted price (should include currency symbol)
        #expect(property.formattedPrice.contains("1,234,567") || property.formattedPrice.contains("1.234.567"))
        
        // Test formatted size (should include unit)
        #expect(property.formattedSize.contains("150") || property.formattedSize.contains("151"))
        
        // Test bathroom text formatting
        #expect(property.bathroomText == "2.5")
        
        // Test price per unit calculation
        #expect(property.formattedPricePerUnit.contains("/"))
    }
    
    @Test func testSampleData() async throws {
        let sampleProperties = PropertyListing.sampleData
        
        // Verify we have sample data
        #expect(sampleProperties.count > 0)
        
        // Verify all sample properties have required fields
        for property in sampleProperties {
            #expect(!property.title.isEmpty)
            #expect(!property.location.isEmpty)
            #expect(property.price > 0)
            #expect(property.size > 0)
            #expect(property.bedrooms >= 0)
            #expect(property.bathrooms > 0)
            #expect(property.propertyRating != nil)
        }
    }
    
    @Test func testPropertyListingLegacyInitializer() async throws {
        // Test the legacy initializer that maps address to location
        let property = PropertyListing(
            title: "Legacy Property",
            address: "456 Legacy Avenue", // Using legacy parameter name
            price: 600000,
            size: 120,
            bedrooms: 3,
            bathrooms: 2.0,
            propertyType: .townhouse,
            rating: 3.5
        )
        
        // Verify address was mapped to location
        #expect(property.location == "456 Legacy Avenue")
        #expect(property.link == nil) // Legacy properties don't have links
        #expect(property.propertyRating == .considering) // Rating 3.5 should map to considering
    }
    
    @Test func testPropertyRatingConversions() async throws {
        // Test PropertyRating to legacy rating conversion
        #expect(PropertyRating.none.toLegacyRating == 0.0)
        #expect(PropertyRating.excluded.toLegacyRating == 1.0)
        #expect(PropertyRating.considering.toLegacyRating == 2.5)
        #expect(PropertyRating.good.toLegacyRating == 4.0)
        #expect(PropertyRating.excellent.toLegacyRating == 5.0)
        
        // Test legacy rating to PropertyRating conversion
        #expect(PropertyRating.fromLegacy(rating: 0.0, isFavorite: false) == .none)
        #expect(PropertyRating.fromLegacy(rating: 1.5, isFavorite: false) == .excluded)
        #expect(PropertyRating.fromLegacy(rating: 3.0, isFavorite: false) == .considering)
        #expect(PropertyRating.fromLegacy(rating: 4.0, isFavorite: false) == .good)
        #expect(PropertyRating.fromLegacy(rating: 5.0, isFavorite: false) == .excellent)
        
        // Test favorite override
        #expect(PropertyRating.fromLegacy(rating: 3.0, isFavorite: true) == .good)
    }
    
    @Test func testPropertyRatingDisplayProperties() async throws {
        // Test that all ratings have display names and system images
        for rating in PropertyRating.allCases {
            #expect(!rating.displayName.isEmpty)
            #expect(!rating.systemImage.isEmpty)
        }
        
        // Test specific display properties
        #expect(PropertyRating.none.displayName == "No Rating")
        #expect(PropertyRating.excellent.displayName == "Excellent")
        #expect(PropertyRating.none.systemImage == "circle")
        #expect(PropertyRating.excellent.systemImage == "star.circle")
    }
    
    @Test func testTagColorProperties() async throws {
        // Test that all tag colors have proper color values
        for tagColor in TagColor.allCases {
            #expect(!tagColor.rawValue.isEmpty)
            #expect(!tagColor.displayName.isEmpty)
            // The rawValue is the color string representation
            #expect(tagColor.rawValue == tagColor.rawValue.lowercased())
        }
    }
    
    @Test func testPropertyUpdateRating() async throws {
        let property = PropertyListing(
            title: "Test Update",
            location: "123 Update Street",
            price: 500000,
            size: 100,
            bedrooms: 2,
            bathrooms: 1.5,
            propertyType: .house,
            propertyRating: PropertyRating.none
        )
        
        let originalDate = property.updatedDate
        
        // Wait a moment to ensure date changes
        try await Task.sleep(nanoseconds: 1_000_000) // 1ms
        
        // Update the rating
        property.updateRating(.excellent)
        
        #expect(property.propertyRating == .excellent)
        #expect(property.rating == 5.0)
        #expect(property.updatedDate > originalDate)
    }
}
