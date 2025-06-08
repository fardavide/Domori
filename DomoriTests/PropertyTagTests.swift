import Testing
import SwiftData
import SwiftUI
@testable import Domori

@Suite("PropertyTag Tests")
struct PropertyTagTests {
    
    @Test("PropertyTag initialization works correctly")
    func testPropertyTagInitialization() {
        let tag = PropertyTag(name: "Test Tag", rating: .excellent)
        
        #expect(tag.name == "Test Tag")
        #expect(tag.rating == .excellent)
        #expect(tag.properties?.isEmpty ?? true)
        #expect(tag.id != UUID(uuidString: "00000000-0000-0000-0000-000000000000"))
    }
    
    @Test("PropertyTag rating color conversion works")
    func testRatingColorConversion() {
        let excellentTag = PropertyTag(name: "Excellent Tag", rating: .excellent)
        let goodTag = PropertyTag(name: "Good Tag", rating: .good)
        let consideringTag = PropertyTag(name: "Considering Tag", rating: .considering)
        let excludedTag = PropertyTag(name: "Excluded Tag", rating: .excluded)
        let noneTag = PropertyTag(name: "None Tag", rating: .none)
        
        #expect(excellentTag.swiftUiColor == .blue)
        #expect(goodTag.swiftUiColor == .green)
        #expect(consideringTag.swiftUiColor == .orange)
        #expect(excludedTag.swiftUiColor == .red)
        #expect(noneTag.swiftUiColor == .gray)
    }
    
    @Test("PropertyTag relationship with PropertyListing")
    func testPropertyTagRelationship() async throws {
        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PropertyListing.self, PropertyTag.self, configurations: config)
        let context = await container.mainContext
        
        // Create a property and tag
        let property = PropertyListing(
            title: "Test Property",
            location: "Test Location",
            price: 100000,
            size: 100,
            bedrooms: 2,
            bathrooms: 1,
            propertyType: .apartment,
            propertyRating: .none
        )
        
        let tag = PropertyTag(name: "Test Tag", rating: .good)
        
        // Add tag to property
        if property.tags == nil {
            property.tags = []
        }
        if tag.properties == nil {
            tag.properties = []
        }
        property.tags?.append(tag)
        tag.properties?.append(property)
        
        // Insert into context
        context.insert(property)
        context.insert(tag)
        
        // Verify relationship
        #expect(property.tags?.count == 1)
        #expect(property.tags?.first?.name == "Test Tag")
        #expect(tag.properties?.count == 1)
        #expect(tag.properties?.first?.title == "Test Property")
    }
} 
