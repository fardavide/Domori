import Testing
import SwiftData
import Foundation
@testable import Domori

@MainActor
struct PropertyListingTests {
    
    @Test("PropertyListing creation with all parameters")
    func propertyListingCreation() {
        let listing = PropertyListing(
            title: "Test Property",
            location: "123 Test Street",
            link: "https://example.com/test",
            agentContact: "+1 (555) 123-4567",
            price: 500000,
            size: 100,
            bedrooms: 2,
            bathrooms: 1.5,
            propertyType: PropertyType.house,
            propertyRating: PropertyRating.good
        )
        
        #expect(listing.title == "Test Property")
        #expect(listing.location == "123 Test Street")
        #expect(listing.link == "https://example.com/test")
        #expect(listing.agentContact == "+1 (555) 123-4567")
        #expect(listing.price == 500000)
        #expect(listing.size == 100)
        #expect(listing.bedrooms == 2)
        #expect(listing.bathrooms == 1.5)
        #expect(listing.propertyType == PropertyType.house)
        #expect(listing.propertyRating == PropertyRating.good)
        #expect(listing.tags?.isEmpty ?? true)
    }
    
    @Test("PropertyListing creation with legacy parameters")
    func propertyListingLegacyCreation() {
        let listing = PropertyListing(
            title: "Legacy Property",
            location: "456 Legacy Avenue",
            price: 750000,
            size: 150,
            bedrooms: 3,
            bathrooms: 2.0,
            propertyType: PropertyType.condo,
            rating: 3.5,
            propertyRating: PropertyRating.considering
        )
        
        #expect(listing.title == "Legacy Property")
        #expect(listing.location == "456 Legacy Avenue")
        #expect(listing.link == nil)
        #expect(listing.agentContact == nil)
        #expect(listing.price == 750000)
        #expect(listing.size == 150)
        #expect(listing.bedrooms == 3)
        #expect(listing.bathrooms == 2.0)
        #expect(listing.propertyType == PropertyType.condo)
        #expect(listing.rating == 3.5)
        #expect(listing.propertyRating == PropertyRating.considering)
    }
    
    @Test("PropertyListing default values")
    func propertyListingDefaults() {
        let listing = PropertyListing(
            title: "Default Property",
            location: "789 Default Road",
            price: 300000,
            size: 80,
            bedrooms: 1,
            bathrooms: 1.0,
            propertyType: PropertyType.apartment
        )
        
        #expect(listing.rating == 0.0)
        #expect(listing.propertyRating == PropertyRating.none)
        #expect(listing.tags?.isEmpty ?? true)
    }
    
    @Test("PropertyListing formatted values")
    func propertyListingFormattedValues() {
        let listing = PropertyListing(
            title: "Format Test",
            location: "123 Format Street",
            price: 1234567,
            size: 150.5,
            bedrooms: 3,
            bathrooms: 2.5,
            propertyType: PropertyType.house
        )
        
        #expect(listing.formattedPrice.contains("1,234,567"))
        #expect(listing.bathroomText == "2.5")
        #expect(!listing.sizeUnit.isEmpty)
        #expect(!listing.formattedPricePerUnit.isEmpty)
    }
    
    @Test("PropertyListing update rating")
    func propertyListingUpdateRating() {
        let listing = PropertyListing(
            title: "Update Test",
            location: "123 Update Street",
            price: 500000,
            size: 100,
            bedrooms: 2,
            bathrooms: 1.5,
            propertyType: PropertyType.house
        )
        
        let originalDate = listing.updatedDate
        
        // Update the rating
        listing.updateRating(PropertyRating.excellent)
        
        #expect(listing.propertyRating == PropertyRating.excellent)
        #expect(listing.rating == 5.0)
        #expect(listing.updatedDate >= originalDate)
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
    
    @Test("PropertyRating legacy conversion")
    func propertyRatingLegacyConversion() {
        // Test fromLegacy conversion
        #expect(PropertyRating.fromLegacy(rating: 0.0, isFavorite: false) == PropertyRating.none)
        #expect(PropertyRating.fromLegacy(rating: 1.5, isFavorite: false) == PropertyRating.excluded)
        #expect(PropertyRating.fromLegacy(rating: 3.0, isFavorite: false) == PropertyRating.considering)
        #expect(PropertyRating.fromLegacy(rating: 4.0, isFavorite: false) == PropertyRating.good)
        #expect(PropertyRating.fromLegacy(rating: 5.0, isFavorite: false) == PropertyRating.excellent)
        
        // Test toLegacyRating conversion
        #expect(PropertyRating.none.toLegacyRating == 0.0)
        #expect(PropertyRating.excluded.toLegacyRating == 1.5)
        #expect(PropertyRating.considering.toLegacyRating == 3.0)
        #expect(PropertyRating.good.toLegacyRating == 4.0)
        #expect(PropertyRating.excellent.toLegacyRating == 5.0)
    }
    
    @Test("Sample data creation")
    func sampleDataCreation() {
        let sampleData = PropertyListing.sampleData
        
        #expect(sampleData.count > 0)
        #expect(sampleData.allSatisfy { !$0.title.isEmpty })
        #expect(sampleData.allSatisfy { !$0.location.isEmpty })
        #expect(sampleData.allSatisfy { $0.price > 0 })
        #expect(sampleData.allSatisfy { $0.size > 0 })
        #expect(sampleData.allSatisfy { $0.bedrooms >= 0 })
        #expect(sampleData.allSatisfy { $0.bathrooms > 0 })
    }
    
    @Test("PropertyListing agent contact functionality")
    func propertyListingAgentContact() {
        // Test with agent contact
        let listingWithContact = PropertyListing(
            title: "Property with Agent",
            location: "123 Agent Street",
            link: "https://example.com/agent-property",
            agentContact: "+1 (555) 987-6543",
            price: 600000,
            size: 120,
            bedrooms: 3,
            bathrooms: 2.0,
            propertyType: PropertyType.house,
            propertyRating: PropertyRating.good
        )
        
        #expect(listingWithContact.agentContact == "+1 (555) 987-6543")
        
        // Test without agent contact
        let listingWithoutContact = PropertyListing(
            title: "Property without Agent",
            location: "456 No Agent Street",
            link: "https://example.com/no-agent-property",
            price: 500000,
            size: 100,
            bedrooms: 2,
            bathrooms: 1.5,
            propertyType: PropertyType.apartment,
            propertyRating: PropertyRating.considering
        )
        
        #expect(listingWithoutContact.agentContact == nil)
        
        // Test with empty string (should be stored as nil)
        let listingWithEmptyContact = PropertyListing(
            title: "Property with Empty Contact",
            location: "789 Empty Contact Street",
            link: "https://example.com/empty-contact",
            agentContact: "",
            price: 400000,
            size: 90,
            bedrooms: 2,
            bathrooms: 1.0,
            propertyType: PropertyType.condo,
            propertyRating: PropertyRating.none
        )
        
        #expect(listingWithEmptyContact.agentContact == "")
    }
} 