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
        propertyRating: .good
    )
    
    #expect(listing.title == "Test Property")
    #expect(listing.address == "123 Test Street")
    #expect(listing.price == 500_000)
    #expect(listing.size == 1500)
    #expect(listing.bedrooms == 3)
    #expect(listing.bathrooms == 2.0)
    #expect(listing.propertyType == .house)
    #expect(listing.rating == 4.0)
    #expect(listing.propertyRating == .good)
    #expect(listing.notes == "Great property for testing")
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
    #expect(listing.propertyRating == .none)
    #expect(listing.notes == "")
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
    
    if #available(macOS 13.0, iOS 16.0, *) {
        let usesMetric = locale.measurementSystem == .metric
        #expect(usesMetric == true || usesMetric == false)
        
        // Test specific locales
        let usLocale = Locale(identifier: "en_US")
        #expect(usLocale.measurementSystem == .us)
        
        let ukLocale = Locale(identifier: "en_GB")
        #expect(ukLocale.measurementSystem == .uk)
        
        let caLocale = Locale(identifier: "en_CA")
        #expect(caLocale.measurementSystem == .metric)
    } else {
        let usesMetric = locale.usesMetricSystem
        #expect(usesMetric == true || usesMetric == false)
        
        // Test specific locales
        let usLocale = Locale(identifier: "en_US")
        #expect(usLocale.usesMetricSystem == false)
        
        let ukLocale = Locale(identifier: "en_GB")
        #expect(ukLocale.usesMetricSystem == false)
        
        let caLocale = Locale(identifier: "en_CA")
        #expect(caLocale.usesMetricSystem == true)
    }
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
    #expect(PropertyRating.fromLegacy(rating: 0.0, isFavorite: false) == .none)
    #expect(PropertyRating.fromLegacy(rating: 1.5, isFavorite: false) == .excluded)
    #expect(PropertyRating.fromLegacy(rating: 3.0, isFavorite: false) == .considering)
    #expect(PropertyRating.fromLegacy(rating: 4.0, isFavorite: false) == .good)
    #expect(PropertyRating.fromLegacy(rating: 5.0, isFavorite: false) == .excellent)
    
    // Test toLegacyRating conversion
    #expect(PropertyRating.none.toLegacyRating == 0.0)
    #expect(PropertyRating.excluded.toLegacyRating == 1.5)
    #expect(PropertyRating.considering.toLegacyRating == 3.0)
    #expect(PropertyRating.good.toLegacyRating == 4.0)
    #expect(PropertyRating.excellent.toLegacyRating == 5.0)
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
    
    // Test some specific properties that should have good or excellent ratings
    #expect(sampleData[1].propertyRating == .good || sampleData[1].propertyRating == .excellent)
    #expect(sampleData[4].propertyRating == .good || sampleData[4].propertyRating == .excellent)
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