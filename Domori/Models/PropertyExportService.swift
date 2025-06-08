import Foundation
import SwiftData
import UniformTypeIdentifiers

// MARK: - Export/Import Data Structures

struct PropertyListingExport: Codable {
    let title: String
    let location: String
    let link: String?
    let agentContact: String?
    let price: Double
    let size: Double
    let bedrooms: Int
    let bathrooms: Double
    let propertyType: String
    let rating: Double
    let propertyRating: String?
    let createdDate: Date
    let updatedDate: Date
    let tags: [PropertyTagExport]?
    
    init(from propertyListing: PropertyListing) {
        self.title = propertyListing.title
        self.location = propertyListing.location
        self.link = propertyListing.link
        self.agentContact = propertyListing.agentContact
        self.price = propertyListing.price
        self.size = propertyListing.size
        self.bedrooms = propertyListing.bedrooms
        self.bathrooms = propertyListing.bathrooms
        self.propertyType = propertyListing.propertyType.rawValue
        self.rating = propertyListing.rating
        self.propertyRating = propertyListing.propertyRating?.rawValue
        self.createdDate = propertyListing.createdDate
        self.updatedDate = propertyListing.updatedDate
        self.tags = propertyListing.tags?.map { PropertyTagExport(from: $0) }
    }
    
    func toPropertyListing() -> PropertyListing {
        let propertyTypeEnum = PropertyType(rawValue: propertyType) ?? .other
        let propertyRatingEnum = propertyRating.flatMap { PropertyRating(rawValue: $0) }
        
        let listing = PropertyListing(
            title: title,
            location: location,
            link: link,
            agentContact: agentContact,
            price: price,
            size: size,
            bedrooms: bedrooms,
            bathrooms: bathrooms,
            propertyType: propertyTypeEnum,
            rating: rating,
            propertyRating: propertyRatingEnum
        )
        
        listing.createdDate = createdDate
        listing.updatedDate = updatedDate
        
        return listing
    }
}

struct PropertyTagExport: Codable {
    let name: String
    let rating: String
    
    init(from propertyTag: PropertyTag) {
        self.name = propertyTag.name
        self.rating = propertyTag.rating.rawValue
    }
    
    func toPropertyTag() -> PropertyTag {
        let ratingEnum = PropertyRating(rawValue: rating) ?? .none
        return PropertyTag(name: name, rating: ratingEnum)
    }
}

struct PropertyListingsExport: Codable {
    let version: String
    let exportDate: Date
    let listings: [PropertyListingExport]
    
    init(listings: [PropertyListing]) {
        self.version = "1.0"
        self.exportDate = Date()
        self.listings = listings.map { PropertyListingExport(from: $0) }
    }
}

// MARK: - Export/Import Service

@Observable
final class PropertyExportService {
    static let shared = PropertyExportService()
    
    private init() {}
    
    // MARK: - Export Functionality
    
    /// Exports all property listings to JSON format
    /// - Parameter context: SwiftData ModelContext for fetching listings
    /// - Returns: JSON data ready for export
    /// - Throws: Encoding errors or fetch errors
    func exportAllListings(context: ModelContext) throws -> Data {
        let descriptor = FetchDescriptor<PropertyListing>()
        let listings = try context.fetch(descriptor)
        
        let exportData = PropertyListingsExport(listings: listings)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        return try encoder.encode(exportData)
    }
    
    /// Exports property listings from a specific workspace to JSON format
    /// - Parameters:
    ///   - workspace: The workspace to export listings from
    ///   - context: SwiftData ModelContext for fetching listings
    /// - Returns: JSON data ready for export
    /// - Throws: Encoding errors or fetch errors
    func exportWorkspaceListings(workspace: SharedWorkspace, context: ModelContext) throws -> Data {
        let workspaceId = workspace.id
        let descriptor = FetchDescriptor<PropertyListing>(
            predicate: #Predicate<PropertyListing> { listing in
                listing.workspace?.id == workspaceId
            }
        )
        let listings = try context.fetch(descriptor)
        
        let exportData = PropertyListingsExport(listings: listings)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        return try encoder.encode(exportData)
    }
    
    // MARK: - Import Functionality
    
    /// Imports property listings from JSON data
    /// - Parameters:
    ///   - data: JSON data containing property listings
    ///   - workspace: Target workspace for imported listings
    ///   - context: SwiftData ModelContext for saving listings
    ///   - replaceExisting: Whether to replace existing listings or add to them
    /// - Returns: ImportResult containing success/failure information
    func importListings(
        from data: Data,
        toWorkspace workspace: SharedWorkspace,
        context: ModelContext,
        replaceExisting: Bool = false
    ) -> ImportResult {
        do {
            let decoder = JSONDecoder()
            // Use flexible date decoding that handles ISO8601 with microseconds
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                // Try ISO8601 with microseconds first
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = formatter.date(from: dateString) {
                    return date
                }
                
                // Fallback to standard ISO8601
                formatter.formatOptions = [.withInternetDateTime]
                if let date = formatter.date(from: dateString) {
                    return date
                }
                
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: decoder.codingPath, 
                                        debugDescription: "Invalid date format: \(dateString)")
                )
            }
            
            let importData = try decoder.decode(PropertyListingsExport.self, from: data)
            
            var importedCount = 0
            var skippedCount = 0
            var errors: [String] = []
            
            // If replacing existing, delete current listings in workspace
            if replaceExisting {
                let workspaceId = workspace.id
                let descriptor = FetchDescriptor<PropertyListing>(
                    predicate: #Predicate<PropertyListing> { listing in
                        listing.workspace?.id == workspaceId
                    }
                )
                let existingListings = try context.fetch(descriptor)
                for listing in existingListings {
                    context.delete(listing)
                }
            }
            
            // Import new listings
            for exportListing in importData.listings {
                do {
                    let newListing = exportListing.toPropertyListing()
                    newListing.workspace = workspace
                    
                    context.insert(newListing)
                    
                    // Handle tags
                    if let tagExports = exportListing.tags {
                        for tagExport in tagExports {
                            // Check if tag already exists in context
                            let tagName = tagExport.name
                            let tagDescriptor = FetchDescriptor<PropertyTag>(
                                predicate: #Predicate<PropertyTag> { tag in
                                    tag.name == tagName
                                }
                            )
                            
                            let existingTags = try context.fetch(tagDescriptor)
                            let tag: PropertyTag
                            
                            if let existingTag = existingTags.first {
                                tag = existingTag
                            } else {
                                tag = tagExport.toPropertyTag()
                                context.insert(tag)
                            }
                            
                            // Associate tag with property
                            if newListing.tags == nil {
                                newListing.tags = []
                            }
                            newListing.tags?.append(tag)
                        }
                    }
                    
                    importedCount += 1
                } catch {
                    skippedCount += 1
                    errors.append("Failed to import '\(exportListing.title)': \(error.localizedDescription)")
                }
            }
            
            // Save context
            try context.save()
            
            return ImportResult(
                success: true,
                importedCount: importedCount,
                skippedCount: skippedCount,
                errors: errors,
                message: "Successfully imported \(importedCount) properties"
            )
            
        } catch {
            return ImportResult(
                success: false,
                importedCount: 0,
                skippedCount: 0,
                errors: [error.localizedDescription],
                message: "Failed to import properties: \(error.localizedDescription)"
            )
        }
    }
    
    // MARK: - Utility Methods
    
    /// Validates JSON data format before import
    /// - Parameter data: JSON data to validate
    /// - Returns: ValidationResult with details about the data
    func validateImportData(_ data: Data) -> ValidationResult {
        do {
            let decoder = JSONDecoder()
            // Use flexible date decoding that handles ISO8601 with microseconds
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                // Try ISO8601 with microseconds first
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = formatter.date(from: dateString) {
                    return date
                }
                
                // Fallback to standard ISO8601
                formatter.formatOptions = [.withInternetDateTime]
                if let date = formatter.date(from: dateString) {
                    return date
                }
                
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: decoder.codingPath, 
                                        debugDescription: "Invalid date format: \(dateString)")
                )
            }
            
            // Debug: Print the JSON string for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🔍 JSON to validate:")
                print(jsonString.prefix(500)) // Print first 500 characters
            }
            
            let importData = try decoder.decode(PropertyListingsExport.self, from: data)
            
            print("✅ Validation successful: \(importData.listings.count) listings")
            
            return ValidationResult(
                isValid: true,
                version: importData.version,
                exportDate: importData.exportDate,
                listingCount: importData.listings.count,
                error: nil
            )
        } catch {
            print("❌ Validation failed: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("Missing key: \(key.stringValue) at \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch for \(type) at \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("Value not found for \(type) at \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("Data corrupted at \(context.codingPath): \(context.debugDescription)")
                @unknown default:
                    print("Unknown decoding error: \(decodingError)")
                }
            }
            
            return ValidationResult(
                isValid: false,
                version: nil,
                exportDate: nil,
                listingCount: 0,
                error: error.localizedDescription
            )
        }
    }
    
    /// Gets supported file types for import/export
    static var supportedFileTypes: [UTType] {
        return [UTType.json]
    }
}

// MARK: - Result Types

struct ImportResult {
    let success: Bool
    let importedCount: Int
    let skippedCount: Int
    let errors: [String]
    let message: String
}

struct ValidationResult {
    let isValid: Bool
    let version: String?
    let exportDate: Date?
    let listingCount: Int
    let error: String?
} 