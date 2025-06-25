import Foundation
import FirebaseFirestore

struct Property: Codable, Hashable {
  @DocumentID var id: String?
  @ServerTimestamp var createdDate: Timestamp?
  var title: String
  var location: String
  var link: String
  var agency: String?
  var price: Double = 0
  var size: Double = 0 // in square meters or square feet based on locale
  var bedrooms: Int = 0
  var bathrooms: Double = 0.0
  var type: PropertyType = .apartment
  var rating: PropertyRating = .none
  @ServerTimestamp var updatedDate: Timestamp?
  var tagIds: [String] = []
  var notes: [PropertyNote]? = []
  var userIds: [String]? = []
  
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
  
  var latestNote: PropertyNote? {
    notes?.sorted { $0.date > $1.date }.first
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
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    
    // Try to find a case-insensitive match
    if let matchedCase = PropertyType.allCases.first(where: { 
      $0.rawValue.lowercased() == rawValue.lowercased() 
    }) {
      self = matchedCase
    } else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Cannot initialize PropertyType from invalid String value \(rawValue)"
      )
    }
  }
  
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

struct PropertyNote: Codable, Hashable, Identifiable {
  var id = UUID()
  var text: String
  var date = Date()
}
