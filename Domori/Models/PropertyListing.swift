import Foundation
import SwiftData

@Model
final class PropertyListing {
    var title: String = ""
    var location: String = "" // Renamed from address
    var link: String? // New mandatory property for new listings, optional for legacy support
    var agentContact: String? // Optional agent phone number for contact
    var price: Double = 0.0
    var size: Double = 0.0 // in square meters or square feet based on locale
    var bedrooms: Int = 0
    var bathrooms: Double = 0.0
    var propertyType: PropertyType = PropertyType.apartment
    var rating: Double = 0.0 // 1-5 stars (legacy)
    
    // New property rating system (added for migration)
    var propertyRating: PropertyRating?
    
    var createdDate: Date = Date()
    var updatedDate: Date = Date()
    
    // Relationships
    @Relationship(deleteRule: .nullify, inverse: \PropertyTag.properties) var tags: [PropertyTag]?
    @Relationship(deleteRule: .nullify, inverse: \SharedWorkspace.properties) var workspace: SharedWorkspace?
    
    init(
        title: String,
        location: String, // Renamed from address
        link: String? = nil, // New optional parameter for link
        agentContact: String? = nil, // Optional agent phone number
        price: Double,
        size: Double,
        bedrooms: Int,
        bathrooms: Double,
        propertyType: PropertyType,
        rating: Double = 0,
        propertyRating: PropertyRating? = nil
    ) {
        self.title = title
        self.location = location // Renamed from address
        self.link = link // New property assignment
        self.agentContact = agentContact // Agent contact assignment
        self.price = price
        self.size = size
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self.propertyType = propertyType
        self.createdDate = Date()
        self.updatedDate = Date()
        self.tags = []
        
        // Handle rating initialization: prioritize the new propertyRating system
        if let propertyRating = propertyRating {
            // New system: propertyRating is explicitly provided
            self.propertyRating = propertyRating
            self.rating = propertyRating.toLegacyRating
        } else if rating > 0 {
            // Legacy system: convert from old rating
            self.propertyRating = PropertyRating.fromLegacy(rating: rating, isFavorite: false)
            self.rating = rating
        } else {
            // Default: no rating
            self.propertyRating = PropertyRating.none
            self.rating = 0.0
        }
    }
    
    // Legacy initializer to support migration from address-based properties
    convenience init(
        title: String,
        address: String, // Legacy parameter name
        price: Double,
        size: Double,
        bedrooms: Int,
        bathrooms: Double,
        propertyType: PropertyType,
        rating: Double = 0,
        propertyRating: PropertyRating? = nil
    ) {
        self.init(
            title: title,
            location: address, // Map address to location
            link: nil, // Legacy listings don't have links
            agentContact: nil, // Legacy listings don't have agent contact
            price: price,
            size: size,
            bedrooms: bedrooms,
            bathrooms: bathrooms,
            propertyType: propertyType,
            rating: rating,
            propertyRating: propertyRating
        )
    }
    
    // Migration helper method - can be called to sync legacy data
    func migrateLegacyRating() {
        let newRating = PropertyRating.fromLegacy(rating: rating, isFavorite: false)
        if propertyRating != newRating {
            propertyRating = newRating
            updatedDate = Date()
        }
    }
    
    // Helper to update rating (updates both new and legacy for compatibility)
    func updateRating(_ newRating: PropertyRating) {
        self.propertyRating = newRating
        self.rating = newRating.toLegacyRating
        self.updatedDate = Date()
    }
    
    // Computed properties with locale-aware formatting
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: price)) ?? formatter.currencySymbol + "0"
    }
    
    var formattedSize: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitOptions = .providedUnit
        measurementFormatter.numberFormatter = formatter
        
        // Use metric system for most of the world, imperial for US, UK, and a few others
        let isMetric = Locale.current.measurementSystem == .metric
        
        if isMetric {
            let measurement = Measurement(value: size, unit: UnitArea.squareMeters)
            return measurementFormatter.string(from: measurement)
        } else {
            let measurement = Measurement(value: size, unit: UnitArea.squareFeet)
            return measurementFormatter.string(from: measurement)
        }
    }
    
    var sizeUnit: String {
        return Locale.current.measurementSystem == .metric ? "m²" : "sq ft"
    }
    
    var formattedPricePerUnit: String {
        let pricePerUnit = price / size
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale.current
        let formattedPrice = formatter.string(from: NSNumber(value: pricePerUnit)) ?? formatter.currencySymbol + "0"
        return "\(formattedPrice)/\(sizeUnit)"
    }
    
    var bathroomText: String {
        if bathrooms == floor(bathrooms) {
            return "\(Int(bathrooms))"
        } else {
            return String(format: "%.1f", bathrooms)
        }
    }
}

enum PropertyType: String, CaseIterable, Codable {
    case house = "House"
    case apartment = "Apartment"
    case condo = "Condo"
    case townhouse = "Townhouse"
    case studio = "Studio"
    case duplex = "Duplex"
    case villa = "Villa"
    case penthouse = "Penthouse"
    case loft = "Loft"
    case other = "Other"
    
    var systemImage: String {
        switch self {
        case .house: return "house"
        case .apartment: return "building"
        case .condo: return "building.2"
        case .townhouse: return "house.lodge"
        case .studio: return "square.stack"
        case .duplex: return "house.and.flag"
        case .villa: return "house.circle"
        case .penthouse: return "building.columns"
        case .loft: return "archivebox"
        case .other: return "questionmark.square"
        }
    }
} 