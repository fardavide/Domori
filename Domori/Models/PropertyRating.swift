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
} 
