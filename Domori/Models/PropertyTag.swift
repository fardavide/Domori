import Foundation
import SwiftData

@Model
final class PropertyTag {
    var name: String
    var color: TagColor
    var createdDate: Date
    
    // Relationship - many-to-many with PropertyListing
    var properties: [PropertyListing] = []
    
    init(name: String, color: TagColor = .blue) {
        self.name = name
        self.color = color
        self.createdDate = Date()
    }
    
    static func createDefaultTags() -> [PropertyTag] {
        [
            PropertyTag(name: "High Priority", color: .red),
            PropertyTag(name: "Good Deal", color: .green),
            PropertyTag(name: "Needs Work", color: .orange),
            PropertyTag(name: "Move-in Ready", color: .blue),
            PropertyTag(name: "Investment", color: .purple),
            PropertyTag(name: "Family Home", color: .pink),
            PropertyTag(name: "Starter Home", color: .mint),
            PropertyTag(name: "Luxury", color: .gold),
            PropertyTag(name: "Waterfront", color: .cyan),
            PropertyTag(name: "City Center", color: .indigo),
            PropertyTag(name: "Quiet Area", color: .teal),
            PropertyTag(name: "Near School", color: .brown)
        ]
    }
}

enum TagColor: String, CaseIterable, Codable {
    case red = "red"
    case orange = "orange"
    case yellow = "yellow"
    case green = "green"
    case mint = "mint"
    case teal = "teal"
    case cyan = "cyan"
    case blue = "blue"
    case indigo = "indigo"
    case purple = "purple"
    case pink = "pink"
    case brown = "brown"
    case gray = "gray"
    case gold = "gold"
    
    var displayName: String {
        switch self {
        case .red: return "Red"
        case .orange: return "Orange"
        case .yellow: return "Yellow"
        case .green: return "Green"
        case .mint: return "Mint"
        case .teal: return "Teal"
        case .cyan: return "Cyan"
        case .blue: return "Blue"
        case .indigo: return "Indigo"
        case .purple: return "Purple"
        case .pink: return "Pink"
        case .brown: return "Brown"
        case .gray: return "Gray"
        case .gold: return "Gold"
        }
    }
} 