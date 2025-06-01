import Testing
import SwiftData
@testable import Domori

@Test("PropertyListing initialization")
func propertyListingCreation() {
    let listing = PropertyListing(
        title: "Test Property",
        address: "123 Test Street",
        price: 500_000,
        size: 1500,
        bedrooms: 3,
        bathrooms: 2.0,
        propertyType: .house,
        rating: 4.5,
        notes: "Great property for testing",
        isFavorite: true
    )
    
    #expect(listing.title == "Test Property")
    #expect(listing.address == "123 Test Street")
    #expect(listing.price == 500_000)
    #expect(listing.size == 1500)
    #expect(listing.bedrooms == 3)
    #expect(listing.bathrooms == 2.0)
    #expect(listing.propertyType == .house)
    #expect(listing.rating == 4.5)
    #expect(listing.notes == "Great property for testing")
    #expect(listing.isFavorite == true)
}

@Test("PropertyListing computed properties")
func propertyListingComputedProperties() {
    let listing = PropertyListing(
        title: "Test Property",
        address: "123 Test Street",
        price: 750_000,
        size: 2000,
        bedrooms: 3,
        bathrooms: 2.5,
        propertyType: .house
    )
    
    #expect(listing.formattedPrice == "$750,000")
    #expect(listing.formattedSize == "2,000 sq ft")
    #expect(listing.bathroomText == "2.5")
}

@Test("PropertyListing bathroom text formatting")
func bathroomTextFormatting() {
    let listing1 = PropertyListing(
        title: "Test Property 1",
        address: "123 Test Street",
        price: 500_000,
        size: 1500,
        bedrooms: 3,
        bathrooms: 2.0,
        propertyType: .house
    )
    
    let listing2 = PropertyListing(
        title: "Test Property 2",
        address: "456 Test Avenue",
        price: 600_000,
        size: 1800,
        bedrooms: 3,
        bathrooms: 2.5,
        propertyType: .condo
    )
    
    #expect(listing1.bathroomText == "2")
    #expect(listing2.bathroomText == "2.5")
}

@Test("PropertyType enum values")
func propertyTypeValues() {
    #expect(PropertyType.house.rawValue == "House")
    #expect(PropertyType.apartment.rawValue == "Apartment")
    #expect(PropertyType.condo.rawValue == "Condo")
    #expect(PropertyType.house.systemImage == "house")
    #expect(PropertyType.apartment.systemImage == "building")
}

@Test("PropertyNote creation and relationships")
func propertyNoteCreation() {
    let note = PropertyNote(content: "This is a test note", category: .pros)
    
    #expect(note.content == "This is a test note")
    #expect(note.category == .pros)
    #expect(note.propertyListing == nil)
}

@Test("PropertyTag creation")
func propertyTagCreation() {
    let tag = PropertyTag(name: "Test Tag", color: .blue)
    
    #expect(tag.name == "Test Tag")
    #expect(tag.color == .blue)
    #expect(tag.properties.isEmpty)
}

@Test("PropertyTag default tags creation")
func defaultTagsCreation() {
    let defaultTags = PropertyTag.createDefaultTags()
    
    #expect(defaultTags.count == 12)
    #expect(defaultTags.contains { $0.name == "High Priority" })
    #expect(defaultTags.contains { $0.name == "Good Deal" })
    #expect(defaultTags.contains { $0.name == "Move-in Ready" })
}

@Test("TagColor enum values")
func tagColorValues() {
    #expect(TagColor.red.displayName == "Red")
    #expect(TagColor.blue.displayName == "Blue")
    #expect(TagColor.green.displayName == "Green")
    #expect(TagColor.red.rawValue == "red")
}

@Test("NoteCategory enum values")
func noteCategoryValues() {
    #expect(NoteCategory.pros.rawValue == "Pros")
    #expect(NoteCategory.cons.rawValue == "Cons")
    #expect(NoteCategory.pros.systemImage == "plus.circle")
    #expect(NoteCategory.cons.systemImage == "minus.circle")
    #expect(NoteCategory.pros.color == "green")
    #expect(NoteCategory.cons.color == "red")
}

@Test("PhotoType enum values and sorting")
func photoTypeValues() {
    #expect(PhotoType.exterior.rawValue == "Exterior")
    #expect(PhotoType.kitchen.rawValue == "Kitchen")
    #expect(PhotoType.exterior.systemImage == "house")
    #expect(PhotoType.kitchen.systemImage == "cooktop")
    
    // Test sort order
    #expect(PhotoType.exterior.sortOrder < PhotoType.interior.sortOrder)
    #expect(PhotoType.interior.sortOrder < PhotoType.kitchen.sortOrder)
}

@Test("Sample data creation")
func sampleDataCreation() {
    let sampleData = PropertyListing.sampleData
    
    #expect(sampleData.count == 6)
    #expect(sampleData[0].title == "Charming Victorian Home")
    #expect(sampleData[1].title == "Modern Downtown Condo")
    #expect(sampleData[1].isFavorite == true)
    #expect(sampleData[4].isFavorite == true)
}

@Test("Sample notes creation")
func sampleNotesCreation() {
    let listing = PropertyListing.sampleData[0]
    let sampleNotes = PropertyListing.createSampleNotes(for: listing)
    
    #expect(sampleNotes.count == 5)
    #expect(sampleNotes.contains { $0.category == .pros })
    #expect(sampleNotes.contains { $0.category == .cons })
    #expect(sampleNotes.contains { $0.category == .questions })
} 