import Testing
import SwiftData
import Foundation
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
    #expect(listing.createdDate <= Date())
    #expect(listing.updatedDate <= Date())
}

@Test("PropertyListing default values")
func propertyListingDefaults() {
    let listing = PropertyListing(
        title: "Test Property",
        address: "123 Test Street",
        price: 500_000,
        size: 1500,
        bedrooms: 3,
        bathrooms: 2.0,
        propertyType: .house
    )
    
    #expect(listing.rating == 0)
    #expect(listing.notes == "")
    #expect(listing.isFavorite == false)
    #expect(listing.propertyNotes.isEmpty)
    #expect(listing.photos.isEmpty)
    #expect(listing.tags.isEmpty)
}

@Test("PropertyListing computed properties formatting")
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
    
    // Test formatted price (should contain currency symbol and number)
    #expect(!listing.formattedPrice.isEmpty)
    #expect(listing.formattedPrice.contains("750"))
    
    // Test formatted size (should contain number and unit)
    #expect(!listing.formattedSize.isEmpty)
    #expect(listing.formattedSize.contains("2"))
    
    // Test size unit (should be metric or imperial)
    #expect(listing.sizeUnit == "m²" || listing.sizeUnit == "sq ft")
    
    // Test bathroom text formatting
    #expect(listing.bathroomText == "2.5")
    
    // Test price per unit
    #expect(!listing.formattedPricePerUnit.isEmpty)
    #expect(listing.formattedPricePerUnit.contains("375"))
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
    
    let listing3 = PropertyListing(
        title: "Test Property 3",
        address: "789 Test Boulevard",
        price: 400_000,
        size: 1200,
        bedrooms: 2,
        bathrooms: 1.0,
        propertyType: .apartment
    )
    
    #expect(listing1.bathroomText == "2")
    #expect(listing2.bathroomText == "2.5")
    #expect(listing3.bathroomText == "1")
}

@Test("PropertyListing price per unit calculation")
func pricePerUnitCalculation() {
    let listing = PropertyListing(
        title: "Test Property",
        address: "123 Test Street",
        price: 1_000_000,
        size: 2000,
        bedrooms: 3,
        bathrooms: 2.0,
        propertyType: .house
    )
    
    // Price per unit should be 500 (1,000,000 / 2000)
    #expect(!listing.formattedPricePerUnit.isEmpty)
    #expect(listing.formattedPricePerUnit.contains("500"))
}

@Test("PropertyListing locale metric system detection")
func localeMetricSystemDetection() {
    let locale = Locale.current
    let usesMetric = locale.usesMetricSystem
    
    // Should return a boolean value
    #expect(usesMetric == true || usesMetric == false)
    
    // Test specific locales
    let usLocale = Locale(identifier: "en_US")
    #expect(usLocale.usesMetricSystem == false)
    
    let ukLocale = Locale(identifier: "en_GB")
    #expect(ukLocale.usesMetricSystem == false)
    
    let caLocale = Locale(identifier: "en_CA")
    #expect(caLocale.usesMetricSystem == true)
}

@Test("PropertyType enum values")
func propertyTypeValues() {
    #expect(PropertyType.house.rawValue == "House")
    #expect(PropertyType.apartment.rawValue == "Apartment")
    #expect(PropertyType.condo.rawValue == "Condo")
    #expect(PropertyType.townhouse.rawValue == "Townhouse")
    #expect(PropertyType.studio.rawValue == "Studio")
    #expect(PropertyType.duplex.rawValue == "Duplex")
    #expect(PropertyType.villa.rawValue == "Villa")
    #expect(PropertyType.penthouse.rawValue == "Penthouse")
    #expect(PropertyType.loft.rawValue == "Loft")
    #expect(PropertyType.other.rawValue == "Other")
    
    // Test system images
    #expect(PropertyType.house.systemImage == "house")
    #expect(PropertyType.apartment.systemImage == "building")
    #expect(PropertyType.condo.systemImage == "building.2")
    #expect(PropertyType.townhouse.systemImage == "house.lodge")
    #expect(PropertyType.studio.systemImage == "square.stack")
    #expect(PropertyType.duplex.systemImage == "house.and.flag")
    #expect(PropertyType.villa.systemImage == "house.circle")
    #expect(PropertyType.penthouse.systemImage == "building.columns")
    #expect(PropertyType.loft.systemImage == "archivebox")
    #expect(PropertyType.other.systemImage == "questionmark.square")
}

@Test("PropertyType case iterable")
func propertyTypeCaseIterable() {
    let allCases = PropertyType.allCases
    #expect(allCases.count == 10)
    #expect(allCases.contains(.house))
    #expect(allCases.contains(.apartment))
    #expect(allCases.contains(.other))
}

@Test("PropertyNote creation and relationships")
func propertyNoteCreation() {
    let note = PropertyNote(content: "This is a test note", category: .pros)
    
    #expect(note.content == "This is a test note")
    #expect(note.category == .pros)
    #expect(note.propertyListing == nil)
    #expect(note.createdDate <= Date())
    #expect(note.updatedDate <= Date())
}

@Test("PropertyNote update content")
func propertyNoteUpdateContent() {
    let note = PropertyNote(content: "Original content", category: .cons)
    let originalDate = note.updatedDate
    
    // Wait a tiny bit to ensure different timestamps
    Thread.sleep(forTimeInterval: 0.001)
    
    note.updateContent("Updated content")
    
    #expect(note.content == "Updated content")
    #expect(note.updatedDate > originalDate)
}

@Test("PropertyTag creation")
func propertyTagCreation() {
    let tag = PropertyTag(name: "Test Tag", color: .blue)
    
    #expect(tag.name == "Test Tag")
    #expect(tag.color == .blue)
    #expect(tag.properties.isEmpty)
    #expect(tag.createdDate <= Date())
}

@Test("PropertyTag default color")
func propertyTagDefaultColor() {
    let tag = PropertyTag(name: "Test Tag")
    
    #expect(tag.color == .blue)
}

@Test("PropertyTag default tags creation")
func defaultTagsCreation() {
    let defaultTags = PropertyTag.createDefaultTags()
    
    #expect(defaultTags.count == 12)
    #expect(defaultTags.contains { $0.name == "High Priority" })
    #expect(defaultTags.contains { $0.name == "Good Deal" })
    #expect(defaultTags.contains { $0.name == "Move-in Ready" })
    #expect(defaultTags.contains { $0.name == "Needs Work" })
    #expect(defaultTags.contains { $0.name == "Investment" })
    #expect(defaultTags.contains { $0.name == "Family Home" })
    #expect(defaultTags.contains { $0.name == "Starter Home" })
    #expect(defaultTags.contains { $0.name == "Luxury" })
    #expect(defaultTags.contains { $0.name == "Waterfront" })
    #expect(defaultTags.contains { $0.name == "City Center" })
    #expect(defaultTags.contains { $0.name == "Quiet Area" })
    #expect(defaultTags.contains { $0.name == "Near School" })
    
    // Test colors are assigned
    #expect(defaultTags.allSatisfy { !$0.name.isEmpty })
    #expect(defaultTags.first { $0.name == "High Priority" }?.color == .red)
    #expect(defaultTags.first { $0.name == "Good Deal" }?.color == .green)
}

@Test("TagColor enum values")
func tagColorValues() {
    #expect(TagColor.red.rawValue == "red")
    #expect(TagColor.orange.rawValue == "orange")
    #expect(TagColor.yellow.rawValue == "yellow")
    #expect(TagColor.green.rawValue == "green")
    #expect(TagColor.mint.rawValue == "mint")
    #expect(TagColor.teal.rawValue == "teal")
    #expect(TagColor.cyan.rawValue == "cyan")
    #expect(TagColor.blue.rawValue == "blue")
    #expect(TagColor.indigo.rawValue == "indigo")
    #expect(TagColor.purple.rawValue == "purple")
    #expect(TagColor.pink.rawValue == "pink")
    #expect(TagColor.brown.rawValue == "brown")
    #expect(TagColor.gray.rawValue == "gray")
    #expect(TagColor.gold.rawValue == "gold")
    
    // Test display names
    #expect(TagColor.red.displayName == "Red")
    #expect(TagColor.blue.displayName == "Blue")
    #expect(TagColor.green.displayName == "Green")
    #expect(TagColor.gold.displayName == "Gold")
}

@Test("TagColor case iterable")
func tagColorCaseIterable() {
    let allCases = TagColor.allCases
    #expect(allCases.count == 14)
    #expect(allCases.contains(.red))
    #expect(allCases.contains(.gold))
}

@Test("NoteCategory enum values")
func noteCategoryValues() {
    #expect(NoteCategory.general.rawValue == "General")
    #expect(NoteCategory.pros.rawValue == "Pros")
    #expect(NoteCategory.cons.rawValue == "Cons")
    #expect(NoteCategory.renovation.rawValue == "Renovation")
    #expect(NoteCategory.inspection.rawValue == "Inspection")
    #expect(NoteCategory.financial.rawValue == "Financial")
    #expect(NoteCategory.neighborhood.rawValue == "Neighborhood")
    #expect(NoteCategory.questions.rawValue == "Questions")
    
    // Test system images
    #expect(NoteCategory.general.systemImage == "note.text")
    #expect(NoteCategory.pros.systemImage == "plus.circle")
    #expect(NoteCategory.cons.systemImage == "minus.circle")
    #expect(NoteCategory.renovation.systemImage == "hammer")
    #expect(NoteCategory.inspection.systemImage == "magnifyingglass")
    #expect(NoteCategory.financial.systemImage == "dollarsign.circle")
    #expect(NoteCategory.neighborhood.systemImage == "location")
    #expect(NoteCategory.questions.systemImage == "questionmark.circle")
    
    // Test colors
    #expect(NoteCategory.general.color == "blue")
    #expect(NoteCategory.pros.color == "green")
    #expect(NoteCategory.cons.color == "red")
    #expect(NoteCategory.renovation.color == "orange")
    #expect(NoteCategory.inspection.color == "purple")
    #expect(NoteCategory.financial.color == "mint")
    #expect(NoteCategory.neighborhood.color == "teal")
    #expect(NoteCategory.questions.color == "yellow")
}

@Test("NoteCategory case iterable")
func noteCategoryCaseIterable() {
    let allCases = NoteCategory.allCases
    #expect(allCases.count == 8)
    #expect(allCases.contains(.general))
    #expect(allCases.contains(.questions))
}

@Test("PropertyPhoto creation")
func propertyPhotoCreation() {
    let imageData = Data()
    let photo = PropertyPhoto(imageData: imageData, caption: "Test caption", photoType: .exterior)
    
    #expect(photo.imageData == imageData)
    #expect(photo.caption == "Test caption")
    #expect(photo.photoType == .exterior)
    #expect(photo.propertyListing == nil)
    #expect(photo.createdDate <= Date())
}

@Test("PropertyPhoto default caption")
func propertyPhotoDefaultCaption() {
    let imageData = Data()
    let photo = PropertyPhoto(imageData: imageData, photoType: .kitchen)
    
    #expect(photo.caption == "")
}

@Test("PropertyPhoto update caption")
func propertyPhotoUpdateCaption() {
    let imageData = Data()
    let photo = PropertyPhoto(imageData: imageData, caption: "Original", photoType: .interior)
    
    photo.updateCaption("Updated caption")
    
    #expect(photo.caption == "Updated caption")
}

@Test("PhotoType enum values and sorting")
func photoTypeValues() {
    #expect(PhotoType.exterior.rawValue == "Exterior")
    #expect(PhotoType.interior.rawValue == "Interior")
    #expect(PhotoType.kitchen.rawValue == "Kitchen")
    #expect(PhotoType.bathroom.rawValue == "Bathroom")
    #expect(PhotoType.bedroom.rawValue == "Bedroom")
    #expect(PhotoType.livingRoom.rawValue == "Living Room")
    #expect(PhotoType.diningRoom.rawValue == "Dining Room")
    #expect(PhotoType.backyard.rawValue == "Backyard")
    #expect(PhotoType.frontYard.rawValue == "Front Yard")
    #expect(PhotoType.garage.rawValue == "Garage")
    #expect(PhotoType.basement.rawValue == "Basement")
    #expect(PhotoType.attic.rawValue == "Attic")
    #expect(PhotoType.floorPlan.rawValue == "Floor Plan")
    #expect(PhotoType.neighborhood.rawValue == "Neighborhood")
    #expect(PhotoType.documents.rawValue == "Documents")
    #expect(PhotoType.other.rawValue == "Other")
    
    // Test system images
    #expect(PhotoType.exterior.systemImage == "house")
    #expect(PhotoType.interior.systemImage == "house.lodge")
    #expect(PhotoType.kitchen.systemImage == "cooktop")
    #expect(PhotoType.bathroom.systemImage == "shower")
    #expect(PhotoType.bedroom.systemImage == "bed.double")
    #expect(PhotoType.livingRoom.systemImage == "sofa")
    #expect(PhotoType.diningRoom.systemImage == "table.furniture")
    #expect(PhotoType.garage.systemImage == "car.garage")
    #expect(PhotoType.documents.systemImage == "doc")
    #expect(PhotoType.other.systemImage == "photo")
    
    // Test sort order
    #expect(PhotoType.exterior.sortOrder < PhotoType.interior.sortOrder)
    #expect(PhotoType.interior.sortOrder < PhotoType.livingRoom.sortOrder)
    #expect(PhotoType.livingRoom.sortOrder < PhotoType.kitchen.sortOrder)
    #expect(PhotoType.kitchen.sortOrder < PhotoType.bedroom.sortOrder)
    #expect(PhotoType.bedroom.sortOrder < PhotoType.bathroom.sortOrder)
    #expect(PhotoType.documents.sortOrder < PhotoType.other.sortOrder)
}

@Test("PhotoType case iterable")
func photoTypeCaseIterable() {
    let allCases = PhotoType.allCases
    #expect(allCases.count == 16)
    #expect(allCases.contains(.exterior))
    #expect(allCases.contains(.other))
}

@Test("Sample data creation")
func sampleDataCreation() {
    let sampleData = PropertyListing.sampleData
    
    #expect(sampleData.count == 6)
    #expect(sampleData[0].title == "Charming Victorian Home")
    #expect(sampleData[1].title == "Modern Downtown Condo")
    
    // Test that properties have proper values
    #expect(sampleData.allSatisfy { !$0.title.isEmpty })
    #expect(sampleData.allSatisfy { !$0.address.isEmpty })
    #expect(sampleData.allSatisfy { $0.price > 0 })
    #expect(sampleData.allSatisfy { $0.size > 0 })
    #expect(sampleData.allSatisfy { $0.bedrooms >= 0 })
    #expect(sampleData.allSatisfy { $0.bathrooms > 0 })
    
    // Test some specific properties that should be favorites
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
    #expect(sampleNotes.contains { $0.category == .neighborhood })
    #expect(sampleNotes.contains { $0.category == .financial })
    
    // Test that all notes have the correct property listing reference
    #expect(sampleNotes.allSatisfy { $0.propertyListing === listing })
    #expect(sampleNotes.allSatisfy { !$0.content.isEmpty })
}

@Test("Sample tags creation")
func sampleTagsCreation() {
    let sampleTags = PropertyListing.createSampleTags()
    
    #expect(sampleTags.count == 12)
    #expect(sampleTags.allSatisfy { !$0.name.isEmpty })
    #expect(sampleTags.allSatisfy { $0.properties.isEmpty })
    
    // Should be the same as default tags
    let defaultTags = PropertyTag.createDefaultTags()
    #expect(sampleTags.map { $0.name } == defaultTags.map { $0.name })
} 