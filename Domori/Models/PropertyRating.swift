import Foundation

enum PropertyRating: String, CaseIterable, Codable {
    case none = "none"
    case excluded = "excluded"
    case considering = "considering"
    case good = "good"
    case excellent = "excellent"
    
    var displayName: String {
        switch self {
        case .none: return "Not Rated"
        case .excluded: return "Excluded"
        case .considering: return "Considering"
        case .good: return "Good"
        case .excellent: return "Excellent"
        }
    }
    
    var color: String {
        switch self {
        case .none: return "gray"
        case .excluded: return "red"
        case .considering: return "yellow"
        case .good: return "green"
        case .excellent: return "blue"
        }
    }
    
    var systemImage: String {
        switch self {
        case .none: return "circle"
        case .excluded: return "xmark.circle.fill"
        case .considering: return "questionmark.circle.fill"
        case .good: return "checkmark.circle.fill"
        case .excellent: return "star.circle.fill"
        }
    }
    
    // Helper method to convert from old Double rating + Bool favorite
    static func fromLegacy(rating: Double, isFavorite: Bool) -> PropertyRating {
        // If it was favorited, it's likely good or excellent
        if isFavorite && rating >= 3.5 {
            return rating >= 4.0 ? .excellent : .good
        }
        
        // Convert rating scale: 0-1 = none, 1.1-2.5 = excluded, 2.6-3.5 = considering, 3.6-4.5 = good, 4.6+ = excellent
        switch rating {
        case 0...1.0:
            return .none
        case 1.1...2.5:
            return .excluded
        case 2.6...3.5:
            return .considering
        case 3.6...4.5:
            return .good
        default:
            return .excellent
        }
    }
    
    // Convert to legacy rating (1-5 stars)
    var toLegacyRating: Double {
        switch self {
        case .none: return 0.0
        case .excluded: return 1.5
        case .considering: return 3.0
        case .good: return 4.0
        case .excellent: return 5.0
        }
    }
    
    // Legacy method - no longer needed since isFavorite field was removed
    // var toLegacyFavorite: Bool {
    //     switch self {
    //     case .none, .excluded, .considering: return false
    //     case .good, .excellent: return true
    //     }
    // }
} 