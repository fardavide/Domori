import Testing
import FirebaseFirestore
import Foundation
@testable import Domori

@MainActor
struct PropertyTests {
    
    @Test("Property creation with all parameters")
    func propertyCreation() {
        let listing = Property(
            title: "Test Property",
            location: "123 Test Street",
            link: "https://example.com/test",
            agentContact: "+1 (555) 123-4567",
            price: 500000,
            size: 100,
            bedrooms: 2,
            bathrooms: 1.5,
            type: .house,
            rating: .good
        )
        
        #expect(listing.title == "Test Property")
        #expect(listing.location == "123 Test Street")
        #expect(listing.link == "https://example.com/test")
        #expect(listing.agentContact == "+1 (555) 123-4567")
        #expect(listing.price == 500000)
        #expect(listing.size == 100)
        #expect(listing.bedrooms == 2)
        #expect(listing.bathrooms == 1.5)
        #expect(listing.type == .house)
        #expect(listing.rating == .good)
        #expect(listing.tagIds.isEmpty)
    }
    
    @Test("Property creation with legacy parameters")
    func propertyLegacyCreation() {
        let listing = Property(
            title: "Legacy Property",
            location: "456 Legacy Avenue",
            link: "https://example.com/legacy",
            agentContact: nil,
            price: 750000,
            size: 150,
            bedrooms: 3,
            bathrooms: 2.0,
            type: .condo,
            rating: .considering
        )
        
        #expect(listing.title == "Legacy Property")
        #expect(listing.location == "456 Legacy Avenue")
        #expect(listing.link == "https://example.com/legacy")
        #expect(listing.agentContact == nil)
        #expect(listing.price == 750000)
        #expect(listing.size == 150)
        #expect(listing.bedrooms == 3)
        #expect(listing.bathrooms == 2.0)
        #expect(listing.type == .condo)
        #expect(listing.rating == .considering)
    }
    
    @Test("Property default values")
    func propertyDefaults() {
        let listing = Property(
            title: "Default Property",
            location: "789 Default Road",
            link: "https://example.com/default",
            agentContact: nil,
            price: 300000,
            size: 80,
            bedrooms: 1,
            bathrooms: 1.0,
            type: .apartment,
            rating: .none
        )
        
        #expect(listing.rating == .none)
        #expect(listing.tagIds.isEmpty)
    }
    
    @Test("Property formatted values")
    func propertyFormattedValues() {
        let listing = Property(
            title: "Format Test",
            location: "123 Format Street",
            link: "https://example.com/format",
            agentContact: nil,
            price: 1234567,
            size: 150.5,
            bedrooms: 3,
            bathrooms: 2.5,
            type: .house,
            rating: .none
        )
        
        #expect(listing.formattedPrice.contains("1,234,567") || listing.formattedPrice.contains("1.234.567"))
        #expect(listing.bathroomText == "2.5")
        #expect(!listing.sizeUnit.isEmpty)
        #expect(!listing.formattedPricePerUnit.isEmpty)
    }
    
    @Test("Property update rating")
    func propertyUpdateRating() {
        let listing = Property(
            title: "Update Test",
            location: "123 Update Street",
            link: "https://example.com/update",
            agentContact: nil,
            price: 500000,
            size: 100,
            bedrooms: 2,
            bathrooms: 1.5,
            type: .house,
            rating: .none
        )
        
        let originalDate = listing.updatedDate
        
        // Note: In Firestore, updates are done through Firestore operations
        // This test verifies the rating assignment works
        var updatedListing = listing
        updatedListing.rating = .excellent
        
        #expect(updatedListing.rating == .excellent)
        #expect(updatedListing.rating != listing.rating)
    }
    
    @Test("PropertyType enum values")
    func propertyTypeValues() {
        #expect(PropertyType.house.rawValue == "House")
        #expect(PropertyType.apartment.rawValue == "Apartment")
        #expect(PropertyType.condo.rawValue == "Condo")
        #expect(PropertyType.townhouse.rawValue == "Townhouse")
        #expect(PropertyType.villa.rawValue == "Villa")
        #expect(PropertyType.studio.rawValue == "Studio")
        #expect(PropertyType.loft.rawValue == "Loft")
        #expect(PropertyType.duplex.rawValue == "Duplex")
        #expect(PropertyType.penthouse.rawValue == "Penthouse")
        #expect(PropertyType.other.rawValue == "Other")
        
        // Test system images
        #expect(PropertyType.house.systemImage == "house")
        #expect(PropertyType.apartment.systemImage == "building")
        #expect(PropertyType.condo.systemImage == "building.2")
        #expect(PropertyType.townhouse.systemImage == "house.lodge")
        #expect(PropertyType.villa.systemImage == "house.circle")
        #expect(PropertyType.studio.systemImage == "square.stack")
        #expect(PropertyType.loft.systemImage == "archivebox")
        #expect(PropertyType.duplex.systemImage == "house.and.flag")
        #expect(PropertyType.penthouse.systemImage == "building.columns")
        #expect(PropertyType.other.systemImage == "questionmark.square")
    }
    
    @Test("PropertyType case iterable")
    func propertyTypeCaseIterable() {
        let allCases = PropertyType.allCases
        #expect(allCases.count == 10)
        #expect(allCases.contains(PropertyType.house))
        #expect(allCases.contains(PropertyType.other))
    }
    
    @Test("PropertyRating enum values")
    func propertyRatingValues() {
        #expect(PropertyRating.none.rawValue == "none")
        #expect(PropertyRating.excluded.rawValue == "excluded")
        #expect(PropertyRating.considering.rawValue == "considering")
        #expect(PropertyRating.good.rawValue == "good")
        #expect(PropertyRating.excellent.rawValue == "excellent")
        
        // Test display names
        #expect(PropertyRating.none.displayName == "Not Rated")
        #expect(PropertyRating.excluded.displayName == "Excluded")
        #expect(PropertyRating.considering.displayName == "Considering")
        #expect(PropertyRating.good.displayName == "Good")
        #expect(PropertyRating.excellent.displayName == "Excellent")
        
        // Test colors
        #expect(PropertyRating.none.color == "gray")
        #expect(PropertyRating.excluded.color == "red")
        #expect(PropertyRating.considering.color == "yellow")
        #expect(PropertyRating.good.color == "green")
        #expect(PropertyRating.excellent.color == "blue")
        
        // Test system images
        #expect(PropertyRating.none.systemImage == "circle")
        #expect(PropertyRating.excluded.systemImage == "xmark.circle.fill")
        #expect(PropertyRating.considering.systemImage == "questionmark.circle.fill")
        #expect(PropertyRating.good.systemImage == "checkmark.circle.fill")
        #expect(PropertyRating.excellent.systemImage == "star.circle.fill")
    }
    
    @Test("Sample data creation")
    func sampleDataCreation() {
        let sampleData = Property.sampleData
        
        #expect(sampleData.count > 0)
        #expect(sampleData.allSatisfy { !$0.title.isEmpty })
        #expect(sampleData.allSatisfy { !$0.location.isEmpty })
        #expect(sampleData.allSatisfy { $0.price > 0 })
        #expect(sampleData.allSatisfy { $0.size > 0 })
        #expect(sampleData.allSatisfy { $0.bedrooms >= 0 })
        #expect(sampleData.allSatisfy { $0.bathrooms > 0 })
    }
    
    @Test("Property agent contact functionality")
    func propertyAgentContact() {
        // Test with agent contact
        let listingWithContact = Property(
            title: "Property with Agent",
            location: "123 Agent Street",
            link: "https://example.com/agent-property",
            agentContact: "+1 (555) 987-6543",
            price: 600000,
            size: 120,
            bedrooms: 3,
            bathrooms: 2.0,
            type: .house,
            rating: .good
        )
        
        #expect(listingWithContact.agentContact == "+1 (555) 987-6543")
        
        // Test without agent contact
        let listingWithoutContact = Property(
            title: "Property without Agent",
            location: "456 No Agent Street",
            link: "https://example.com/no-agent-property",
            agentContact: nil,
            price: 500000,
            size: 100,
            bedrooms: 2,
            bathrooms: 1.5,
            type: .apartment,
            rating: .considering
        )
        
        #expect(listingWithoutContact.agentContact == nil)
        
        // Test with empty agent contact
        let listingWithEmptyContact = Property(
            title: "Property with Empty Contact",
            location: "789 Empty Contact Street",
            link: "https://example.com/empty-contact",
            agentContact: "",
            price: 400000,
            size: 90,
            bedrooms: 2,
            bathrooms: 1.0,
            type: .condo,
            rating: .none
        )
        
        #expect(listingWithEmptyContact.agentContact == "")
    }
} 
