//

import Testing
import SwiftData
import SwiftUI
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
        
        // Create tags using PropertyRating instead of colors
        let tag1 = PropertyTag(name: "Great Location", rating: .good)
        let tag2 = PropertyTag(name: "Needs Work", rating: .considering)
        
        // Add tags to property
        if property.tags == nil {
            property.tags = []
        }
        property.tags?.append(contentsOf: [tag1, tag2])
        
        // Insert into context
        context.insert(property)
        context.insert(tag1)
        context.insert(tag2)
        
        // Verify tags are associated with property
        #expect(property.tags?.count == 2)
        #expect(property.tags?.contains { $0.name == "Great Location" } ?? false)
        #expect(property.tags?.contains { $0.name == "Needs Work" } ?? false)
    }
    
    @Test func testPropertyTagCreation() async throws {
        // Test that we can create tags with different ratings
        let tagRatings: [PropertyRating] = [.excellent, .good, .considering, .excluded, .none]
        
        for (index, rating) in tagRatings.enumerated() {
            let tag = PropertyTag(name: "Test tag \(index)", rating: rating)
            #expect(tag.name == "Test tag \(index)")
            #expect(tag.rating == rating)
            #expect(tag.properties?.isEmpty ?? true)
            
            // Verify the color mapping works
            let expectedColor: Color
            switch rating {
            case .none: expectedColor = .gray
            case .excluded: expectedColor = .red
            case .considering: expectedColor = .orange
            case .good: expectedColor = .green
            case .excellent: expectedColor = .blue
            }
            #expect(tag.swiftUiColor == expectedColor)
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
    
    @Test func testPropertyRatingDisplayProperties() async throws {
        // Test that all ratings have display names and system images
        for rating in PropertyRating.allCases {
            #expect(!rating.displayName.isEmpty)
            #expect(!rating.systemImage.isEmpty)
        }
        
        // Test specific display properties
        #expect(PropertyRating.none.displayName == "Not Rated")
        #expect(PropertyRating.excellent.displayName == "Excellent")
        #expect(PropertyRating.none.systemImage == "circle")
        #expect(PropertyRating.excellent.systemImage == "star.circle.fill")
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
        #expect(property.updatedDate > originalDate)
    }
}
