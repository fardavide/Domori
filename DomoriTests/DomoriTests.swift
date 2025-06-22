import Testing
import FirebaseFirestore
import SwiftUI
import Foundation
@testable import Domori

@MainActor
struct DomoriTests {
  
  @Test func ensureTestDatabase() async throws {
    let firestore = try await Firestore.createTestFirestore()
    #expect(try await firestore.collection(.properties).getDocuments().isEmpty)
  }
  
  @Test func testPropertyCreation() async throws {
    let firestore = try await Firestore.createTestFirestore()
    
    // Create a test property
    var property = Property(
      title: "Test Property",
      location: "123 Test Street",
      link: "https://example.com/test",
      agentContact: nil,
      price: 500000,
      size: 100,
      bedrooms: 2,
      bathrooms: 1.5,
      type: .house,
      rating: .good
    )
    
    // Add to Firestore
    let docRef = try firestore.setProperty(property)
    
    // Fetch and verify the property was created correctly
    let fetchedProperty = try await firestore.getProperty(withId: docRef.documentID)
    
    // Update Firestore manager fields
    property.id = fetchedProperty.id
    property.createdDate = fetchedProperty.createdDate
    property.updatedDate = fetchedProperty.updatedDate
    
    #expect(fetchedProperty == property)
  }
  
  @Test func testPropertyWithTags() async throws {
    let firestore = try await Firestore.createTestFirestore()
    
    // Create tags first
    let tag1 = PropertyTag(name: "Great Location", rating: .good)
    let tag2 = PropertyTag(name: "Needs Work", rating: .considering)
    
    let tag1Ref = try firestore.setTag(tag1)
    let tag2Ref = try firestore.setTag(tag2)
    
    // Create a test property with tag references
    var property = Property(
      title: "Test Property with Tags",
      location: "456 Tag Street",
      link: "https://example.com/tags",
      agentContact: nil,
      price: 750000,
      size: 150,
      bedrooms: 3,
      bathrooms: 2.0,
      type: .condo,
      rating: .excellent
    )
    
    // Add tag IDs to property
    property.tagIds = [tag1Ref.documentID, tag2Ref.documentID]
    
    // Add property to Firestore
    let propertyRef = try firestore.setProperty(property)
    
    // Fetch and verify
    let fetchedProperty = try await firestore.getProperty(withId: propertyRef.documentID)
    
    #expect(fetchedProperty.tagIds.count == 2)
    #expect(fetchedProperty.tagIds.contains(tag1Ref.documentID))
    #expect(fetchedProperty.tagIds.contains(tag2Ref.documentID))
  }
  
  @Test func testPropertyFormattedValues() async throws {
    let property = Property(
      title: "Test Formatting",
      location: "123 Format Street",
      link: "https://example.com/format",
      agentContact: nil,
      price: 1234567,
      size: 150.5,
      bedrooms: 3,
      bathrooms: 2.5,
      type: .house,
      rating: .good
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
    let sampleProperties = Property.sampleData
    
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
      #expect(property.rating != .none)
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
}
