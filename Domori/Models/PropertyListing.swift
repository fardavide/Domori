import Foundation
import SwiftData

@Model
final class PropertyListing {
    var title: String
    var address: String
    var price: Double
    var size: Double // in square meters or square feet based on locale
    var bedrooms: Int
    var bathrooms: Double
    var propertyType: PropertyType
    var rating: Double // 1-5 stars (legacy)
    var notes: String
    
    // New property rating system (added for migration)
    var propertyRating: PropertyRating?
    
    var createdDate: Date
    var updatedDate: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade) var propertyNotes: [PropertyNote] = []
    @Relationship(deleteRule: .cascade) var photos: [PropertyPhoto] = []
    @Relationship(deleteRule: .nullify) var tags: [PropertyTag] = []
    
    init(
        title: String,
        address: String,
        price: Double,
        size: Double,
        bedrooms: Int,
        bathrooms: Double,
        propertyType: PropertyType,
        rating: Double = 0,
        notes: String = "",
        propertyRating: PropertyRating? = nil
    ) {
        self.title = title
        self.address = address
        self.price = price
        self.size = size
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self.propertyType = propertyType
        self.notes = notes
        self.createdDate = Date()
        self.updatedDate = Date()
        
        // Handle migration: if propertyRating is provided, use it; otherwise convert from legacy
        if let propertyRating = propertyRating {
            self.propertyRating = propertyRating
            // Update legacy properties to match new rating
            self.rating = propertyRating.toLegacyRating
        } else {
            // Convert from legacy rating system
            self.rating = rating
            // Convert legacy data to new rating, or use .none if no legacy data
            if rating > 0 {
                self.propertyRating = PropertyRating.fromLegacy(rating: rating, isFavorite: false)
            } else {
                self.propertyRating = .none
            }
        }
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
        let isMetric = Locale.current.usesMetricSystem
        
        if isMetric {
            let measurement = Measurement(value: size, unit: UnitArea.squareMeters)
            return measurementFormatter.string(from: measurement)
        } else {
            let measurement = Measurement(value: size, unit: UnitArea.squareFeet)
            return measurementFormatter.string(from: measurement)
        }
    }
    
    var sizeUnit: String {
        return Locale.current.usesMetricSystem ? "m²" : "sq ft"
    }
    
    var bathroomText: String {
        if bathrooms.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(bathrooms))"
        } else {
            return String(format: "%.1f", bathrooms)
        }
    }
    
    // Price per unit area with locale formatting
    var formattedPricePerUnit: String {
        let pricePerUnit = price / size
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale.current
        
        let formattedPrice = formatter.string(from: NSNumber(value: pricePerUnit)) ?? "0"
        return "\(formattedPrice)/\(sizeUnit)"
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