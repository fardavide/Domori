import Foundation

enum PropertyRating: String, CaseIterable, Codable, Comparable {
  case none = "none"
  case excluded = "excluded"
  case considering = "considering"
  case good = "good"
  case excellent = "excellent"
  
  static func < (lhs: PropertyRating, rhs: PropertyRating) -> Bool {
    lhs.sortValue < rhs.sortValue
  }
  
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
  
  private var sortValue: Int {
    switch self {
    case .none: return 0
    case .excluded: return 1
    case .considering: return 2
    case .good: return 3
    case .excellent: return 4
    }
  }
}
