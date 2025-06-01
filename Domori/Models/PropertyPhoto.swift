import Foundation
import SwiftData

@Model
final class PropertyPhoto {
    var imageData: Data
    var caption: String
    var photoType: PhotoType
    var createdDate: Date
    
    // Relationship
    var propertyListing: PropertyListing?
    
    init(imageData: Data, caption: String = "", photoType: PhotoType) {
        self.imageData = imageData
        self.caption = caption
        self.photoType = photoType
        self.createdDate = Date()
    }
    
    func updateCaption(_ newCaption: String) {
        self.caption = newCaption
    }
}

enum PhotoType: String, CaseIterable, Codable {
    case exterior = "Exterior"
    case interior = "Interior"
    case kitchen = "Kitchen"
    case bathroom = "Bathroom"
    case bedroom = "Bedroom"
    case livingRoom = "Living Room"
    case diningRoom = "Dining Room"
    case backyard = "Backyard"
    case frontYard = "Front Yard"
    case garage = "Garage"
    case basement = "Basement"
    case attic = "Attic"
    case floorPlan = "Floor Plan"
    case neighborhood = "Neighborhood"
    case documents = "Documents"
    case other = "Other"
    
    var systemImage: String {
        switch self {
        case .exterior: return "house"
        case .interior: return "house.lodge"
        case .kitchen: return "cooktop"
        case .bathroom: return "shower"
        case .bedroom: return "bed.double"
        case .livingRoom: return "sofa"
        case .diningRoom: return "table.furniture"
        case .backyard: return "tree"
        case .frontYard: return "leaf"
        case .garage: return "car.garage"
        case .basement: return "stairs"
        case .attic: return "triangle"
        case .floorPlan: return "square.grid.3x3"
        case .neighborhood: return "location"
        case .documents: return "doc"
        case .other: return "photo"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .exterior: return 0
        case .interior: return 1
        case .livingRoom: return 2
        case .kitchen: return 3
        case .bedroom: return 4
        case .bathroom: return 5
        case .diningRoom: return 6
        case .frontYard: return 7
        case .backyard: return 8
        case .garage: return 9
        case .basement: return 10
        case .attic: return 11
        case .floorPlan: return 12
        case .neighborhood: return 13
        case .documents: return 14
        case .other: return 15
        }
    }
} 