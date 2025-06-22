import Foundation
import FirebaseCore
import UniformTypeIdentifiers
import FirebaseFirestore

@Observable
final class PropertyExportService {
  static let shared = PropertyExportService()
  
  private init() {}
  
  // MARK: - Export Functionality
  
  /// Exports all property listings to JSON format
  /// - Returns: JSON data ready for export
  /// - Throws: Encoding errors or fetch errors
  func exportAllListings(firestore: Firestore) async throws -> Data {
    let properties = try await firestore.collection(.properties)
      .getDocuments()
      .documents
      .map { try $0.data(as: Property.self) }
    
    let tags = try await firestore.collection(.tags)
      .getDocuments()
      .documents
      .map { try $0.data(as: PropertyTag.self) }
    
    let exportData = ExportData(properties: properties, tags: tags)
    
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    
    return try encoder.encode(exportData)
  }
  
  // MARK: - Import Functionality
  
  /// Imports property listings from JSON data
  /// - Parameters:
  ///   - data: JSON data containing property listings
  /// - Returns: ImportResult containing success/failure information
  func importListings(
    from data: Data,
    firestore: Firestore
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
          DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Invalid date format: \(dateString)")
        )
      }
      
      let importData = try decoder.decode(ExportData.self, from: data)
      
      var importedCount = 0
      var skippedCount = 0
      var errors: [String] = []
      
      let batchWrite = firestore.batch()

      // Import properties
      for property in importData.properties {
        let documentReference = firestore.collection(.properties).document()
        do {
          try batchWrite.setData(from: property, forDocument: documentReference)
          importedCount += 1
        } catch {
          skippedCount += 1
          errors.append("Failed to import property \(property.title): \(error.localizedDescription)")
        }
      }
      
      // Import tags
      for tag in importData.tags {
        let documentReference = firestore.collection(.tags).document()
        do {
          try batchWrite.setData(from: tag, forDocument: documentReference)
        } catch {
          errors.append("Failed to import tag \(tag): \(error.localizedDescription)")
        }
      }
    
      batchWrite.commit()
      
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
      
      let importData = try decoder.decode(ExportData.self, from: data)
      
      print("✅ Validation successful: \(importData.properties.count) properties")
      
      return .valid
    } catch {
      print("❌ Validation failed: \(error)")
      return .invalid(error: error)
    }
  }
  
  /// Gets supported file types for import/export
  static var supportedFileTypes: [UTType] {
    return [UTType.json]
  }
}

struct ExportData: Codable {
  let properties: [Property]
  let tags: [PropertyTag]
}

// MARK: - Result Types

struct ImportResult {
  let success: Bool
  let importedCount: Int
  let skippedCount: Int
  let errors: [String]
  let message: String
}

enum ValidationResult {
  case valid
  case invalid(error: Error)
}
