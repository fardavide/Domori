//

import Testing
import SwiftData
import Foundation
@testable import Domori

struct DomoriTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @MainActor
    @Test("App integration test - Create property with relationships")
    func createPropertyWithRelationships() throws {
        // Create an in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PropertyListing.self, PropertyNote.self, PropertyTag.self, PropertyPhoto.self, configurations: config)
        let context = container.mainContext
        
        // Create a property
        let property = PropertyListing(
            title: "Test Integration Property",
            address: "123 Integration Street",
            price: 800_000,
            size: 1800,
            bedrooms: 3,
            bathrooms: 2.5,
            propertyType: .house,
            rating: 4.0,
            propertyRating: .good
        )
        
        // Create notes
        let prosNote = PropertyNote(content: "Great location", category: .pros)
        let consNote = PropertyNote(content: "Needs new roof", category: .cons)
        prosNote.propertyListing = property
        consNote.propertyListing = property
        property.propertyNotes.append(prosNote)
        property.propertyNotes.append(consNote)
        
        // Create tags
        let tag1 = PropertyTag(name: "High Priority", color: .red)
        let tag2 = PropertyTag(name: "Good Deal", color: .green)
        property.tags.append(tag1)
        property.tags.append(tag2)
        tag1.properties.append(property)
        tag2.properties.append(property)
        
        // Create photo
        let photoData = Data([1, 2, 3, 4])
        let photo = PropertyPhoto(imageData: photoData, caption: "Front view", photoType: .exterior)
        photo.propertyListing = property
        property.photos.append(photo)
        
        // Insert into context
        context.insert(property)
        context.insert(prosNote)
        context.insert(consNote)
        context.insert(tag1)
        context.insert(tag2)
        context.insert(photo)
        
        try context.save()
        
        // Verify relationships
        #expect(property.propertyNotes.count == 2)
        #expect(property.tags.count == 2)
        #expect(property.photos.count == 1)
        #expect(prosNote.propertyListing === property)
        #expect(tag1.properties.contains(property))
        #expect(photo.propertyListing === property)
    }
    
    @Test("App integration test - Property filtering and sorting")
    func propertyFilteringAndSorting() throws {
        // Create sample properties with different attributes
        let properties = [
            PropertyListing(title: "A Cheap House", address: "1 A St", price: 200_000, size: 1000, bedrooms: 2, bathrooms: 1, propertyType: .house, rating: 2.0),
            PropertyListing(title: "B Expensive Condo", address: "2 B St", price: 800_000, size: 1200, bedrooms: 2, bathrooms: 2, propertyType: .condo, rating: 5.0, propertyRating: .excellent),
            PropertyListing(title: "C Medium Apartment", address: "3 C St", price: 400_000, size: 1100, bedrooms: 3, bathrooms: 1.5, propertyType: .apartment, rating: 3.5),
        ]
        
        // Test sorting by price
        let sortedByPrice = properties.sorted { $0.price < $1.price }
        #expect(sortedByPrice[0].title == "A Cheap House")
        #expect(sortedByPrice[2].title == "B Expensive Condo")
        
        // Test sorting by rating
        let sortedByRating = properties.sorted { $0.rating > $1.rating }
        #expect(sortedByRating[0].rating == 5.0)
        #expect(sortedByRating[2].rating == 2.0)
        
        // Test filtering by property rating
        let ratedProperties = properties.filter { $0.propertyRating != nil && $0.propertyRating != PropertyRating.none }
        #expect(ratedProperties.count == 1)
        #expect(ratedProperties[0].title == "B Expensive Condo")
        
        // Test filtering by property type
        let houses = properties.filter { $0.propertyType == PropertyType.house }
        #expect(houses.count == 1)
        #expect(houses[0].title == "A Cheap House")
    }
    
    @Test("App integration test - Note categories validation")
    func noteCategoriesValidation() {
        let property = PropertyListing(
            title: "Test Property",
            address: "Test Address",
            price: 500_000,
            size: 1500,
            bedrooms: 3,
            bathrooms: 2,
            propertyType: .house
        )
        
        // Test creating notes for all categories
        for category in NoteCategory.allCases {
            let note = PropertyNote(content: "Test \(category.rawValue) note", category: category)
            note.propertyListing = property
            property.propertyNotes.append(note)
            
            #expect(note.category == category)
            #expect(!note.content.isEmpty)
        }
        
        #expect(property.propertyNotes.count == NoteCategory.allCases.count)
        
        // Test that each category has unique color and icon
        let categories = NoteCategory.allCases
        let colors = Set(categories.map { $0.color })
        let icons = Set(categories.map { $0.systemImage })
        
        #expect(colors.count == categories.count) // All unique colors
        #expect(icons.count == categories.count) // All unique icons
    }
    
    @Test("App integration test - Tag color validation")
    func tagColorValidation() {
        // Test that all tag colors are unique and valid
        let allColors = TagColor.allCases
        let colorNames = Set(allColors.map { $0.rawValue })
        let displayNames = Set(allColors.map { $0.displayName })
        
        #expect(colorNames.count == allColors.count) // All unique raw values
        #expect(displayNames.count == allColors.count) // All unique display names
        
        // Test creating tags with all colors
        for color in allColors {
            let tag = PropertyTag(name: "Test \(color.displayName)", color: color)
            #expect(tag.color == color)
            #expect(tag.name.contains(color.displayName))
        }
    }
    
    @Test("App integration test - Photo type validation")
    func photoTypeValidation() {
        let photoData = Data([1, 2, 3, 4, 5])
        
        // Test creating photos for all types
        for photoType in PhotoType.allCases {
            let photo = PropertyPhoto(imageData: photoData, caption: "Test \(photoType.rawValue)", photoType: photoType)
            
            #expect(photo.photoType == photoType)
            #expect(!photo.caption.isEmpty)
            #expect(photo.imageData == photoData)
        }
        
        // Test sort order is consistent
        let sortedTypes = PhotoType.allCases.sorted { $0.sortOrder < $1.sortOrder }
        #expect(sortedTypes.first == .exterior)
        #expect(sortedTypes.last == .other)
        
        // Test that all have unique system images
        let images = Set(PhotoType.allCases.map { $0.systemImage })
        #expect(images.count == PhotoType.allCases.count)
    }
    
    @Test("App integration test - Currency formatting across locales")
    func currencyFormattingAcrossLocales() {
        let property = PropertyListing(
            title: "Test Property",
            address: "Test Address",
            price: 1_500_000,
            size: 2000,
            bedrooms: 4,
            bathrooms: 3,
            propertyType: .house
        )
        
        // Test that formatting methods return non-empty strings
        #expect(!property.formattedPrice.isEmpty)
        #expect(!property.formattedSize.isEmpty)
        #expect(!property.formattedPricePerUnit.isEmpty)
        
        // Test that price contains the expected number
        #expect(property.formattedPrice.contains("1") && property.formattedPrice.contains("5"))
        
        // Test that size unit is appropriate
        #expect(property.sizeUnit == "m²" || property.sizeUnit == "sq ft")
        
        // Test price per unit calculation (1,500,000 / 2000 = 750)
        #expect(property.formattedPricePerUnit.contains("750"))
    }
    
    @Test("App integration test - Property type system images")
    func propertyTypeSystemImages() {
        // Test that all property types have valid system images
        for propertyType in PropertyType.allCases {
            let property = PropertyListing(
                title: "Test \(propertyType.rawValue)",
                address: "Test Address",
                price: 500_000,
                size: 1500,
                bedrooms: 2,
                bathrooms: 1,
                propertyType: propertyType
            )
            
            #expect(property.propertyType == propertyType)
            #expect(!propertyType.systemImage.isEmpty)
            #expect(!propertyType.rawValue.isEmpty)
        }
        
        // Test that system images are unique
        let images = Set(PropertyType.allCases.map { $0.systemImage })
        #expect(images.count == PropertyType.allCases.count)
    }
    
    @Test("App integration test - Sample data consistency")
    func sampleDataConsistency() {
        // Test sample data consistency
        let sampleData = PropertyListing.sampleData
        #expect(sampleData.count > 0, "Should have sample data")
        
        // Test that all properties have valid data
        for property in sampleData {
            #expect(!property.title.isEmpty, "Property should have a title")
            #expect(!property.address.isEmpty, "Property should have an address")
            #expect(property.price > 0, "Property should have a positive price")
            #expect(property.size > 0, "Property should have a positive size")
        }
        
        // Test that addresses are unique
        let uniqueAddresses = Set(sampleData.map { $0.address })
        #expect(uniqueAddresses.count == sampleData.count)
    }
    
    @Test("PropertyDetailBadge creation and validation")
    func testPropertyDetailBadge() {
        let badge = PropertyDetailBadge(icon: "bed.double", value: "3", label: "beds")
        // Just verify the badge can be created - we can't easily test SwiftUI view properties
        #expect(badge.icon == "bed.double")
        #expect(badge.value == "3")
        #expect(badge.label == "beds")
        
        // Test different badge types
        let bathBadge = PropertyDetailBadge(icon: "shower", value: "2", label: "baths")
        #expect(bathBadge.icon == "shower")
        #expect(bathBadge.value == "2")
        #expect(bathBadge.label == "baths")
        
        let sizeBadge = PropertyDetailBadge(icon: "square", value: "1200", label: "sq ft")
        #expect(sizeBadge.icon == "square")
        #expect(sizeBadge.value == "1200")
        #expect(sizeBadge.label == "sq ft")
    }
    
    @Test("PropertyListRowView with rating validation")
    func testPropertyListRowViewWithRating() {
        let listing = PropertyListing.sampleData[0] // Should have excellent rating
        let rowView = PropertyListRowView(
            listing: listing,
            isSelected: false,
            onSelectionChanged: { _ in }
        )
        
        // Test that the row view can be created
        #expect(rowView.listing.title == listing.title)
        
        // Test that rating is properly displayed
        if let rating = listing.propertyRating {
            #expect(rating != PropertyRating.none)
            #expect(!rating.systemImage.isEmpty)
            #expect(!rating.color.isEmpty)
        }
    }
    
    @Test("PropertyListRowView without rating validation")
    func testPropertyListRowViewWithoutRating() {
        var listing = PropertyListing.sampleData[0]
        listing.propertyRating = PropertyRating.none
        
        let rowView = PropertyListRowView(
            listing: listing,
            isSelected: false,
            onSelectionChanged: { _ in }
        )
        
        #expect(rowView.listing.title == listing.title)
        #expect(listing.propertyRating == PropertyRating.none)
    }
    
    @Test("PropertyListRowView selection handling")
    func testPropertyListRowViewSelection() {
        let listing = PropertyListing.sampleData[0]
        var selectionChanged = false
        var selectedState = false
        
        let rowView = PropertyListRowView(
            listing: listing,
            isSelected: false,
            onSelectionChanged: { isSelected in
                selectionChanged = true
                selectedState = isSelected
            }
        )
        
        #expect(rowView.listing.title == listing.title)
        #expect(rowView.isSelected == false)
        
        // Note: In a real test environment, we would simulate the tap gesture
        // For now, we just verify the callback structure is correct
        #expect(selectionChanged == false) // Not triggered until tap
    }
}
