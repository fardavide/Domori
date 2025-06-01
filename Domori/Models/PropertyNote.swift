import Foundation
import SwiftData

@Model
final class PropertyNote {
    var content: String
    var category: NoteCategory
    var createdDate: Date
    var updatedDate: Date
    
    // Relationship
    var propertyListing: PropertyListing?
    
    init(content: String, category: NoteCategory) {
        self.content = content
        self.category = category
        self.createdDate = Date()
        self.updatedDate = Date()
    }
    
    func updateContent(_ newContent: String) {
        self.content = newContent
        self.updatedDate = Date()
    }
}

enum NoteCategory: String, CaseIterable, Codable {
    case general = "General"
    case pros = "Pros"
    case cons = "Cons"
    case renovation = "Renovation"
    case inspection = "Inspection"
    case financial = "Financial"
    case neighborhood = "Neighborhood"
    case questions = "Questions"
    
    var systemImage: String {
        switch self {
        case .general: return "note.text"
        case .pros: return "plus.circle"
        case .cons: return "minus.circle"
        case .renovation: return "hammer"
        case .inspection: return "magnifyingglass"
        case .financial: return "dollarsign.circle"
        case .neighborhood: return "location"
        case .questions: return "questionmark.circle"
        }
    }
    
    var color: String {
        switch self {
        case .general: return "blue"
        case .pros: return "green"
        case .cons: return "red"
        case .renovation: return "orange"
        case .inspection: return "purple"
        case .financial: return "mint"
        case .neighborhood: return "teal"
        case .questions: return "yellow"
        }
    }
} 