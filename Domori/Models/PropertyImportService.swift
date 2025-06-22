import Foundation
import FirebaseCore
import UniformTypeIdentifiers
import FirebaseFirestore

@Observable
final class PropertyImportService {
  static let shared = PropertyImportService()
  
  private init() {}
  
  // MARK: - Import Functionality
  
  /// Imports property listings from JSON data
  /// - Parameters:
  ///   - data: JSON data containing property listings
  /// - Returns: ImportResult containing success/failure information
  func importListings(
    from data: Data,
    firestore: Firestore
  ) throws -> ImportResult {
    let importData = try JSONSerialization.jsonObject(
      with: data,
      options: []
    ) as! [String: Any]
    
    let batchWrite = firestore.batch()
    
    // Import properties
    let properties = importData["properties"] as! [[String: Any]]
    for property in properties {
      let documentReference = firestore.collection(.properties).document()
      batchWrite.setData(property, forDocument: documentReference)
    }
    
    // Import tags
    let tags = importData["tags"] as! [[String: Any]]
    for tag in tags {
      let documentReference = firestore.collection(.tags).document()
      batchWrite.setData(tag, forDocument: documentReference)
    }
    
    batchWrite.commit()
    
    return ImportResult(
      success: true,
      importedCount: properties.count,
      message: "Successfully imported \(properties.count) properties"
    )
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
      
      return .validWithCount(propertyCount: importData.properties.count)
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
  let message: String
}

enum ValidationResult {
  case valid
  case invalid(error: Error)
  case validWithCount(propertyCount: Int)
  
  var isValid: Bool {
    switch self {
    case .valid, .validWithCount: return true
    case .invalid: return false
    }
  }
  
  var listingCount: Int {
    switch self {
    case .valid: return 0
    case .validWithCount(let count): return count
    case .invalid: return 0
    }
  }
  
  var error: Error? {
    switch self {
    case .valid, .validWithCount: return nil
    case .invalid(let error): return error
    }
  }
}
