import Foundation
@preconcurrency import FirebaseFirestore

final class PropertyImportService {
  /// Parses and validates the JSON payload, returning a PropertyImportData object or throwing a descriptive error.
  func parseAndValidate(_ jsonString: String) throws -> PropertyImportData {
    guard let jsonData = jsonString.data(using: .utf8) else {
      throw ImportError.invalidJsonEncoding
    }
    do {
      let decoder = JSONDecoder()
      let importData = try decoder.decode(PropertyImportData.self, from: jsonData)
      return importData
    } catch let decodingError as DecodingError {
      // Handle missing required fields specifically
      switch decodingError {
      default:
        throw ImportError.jsonDecodingFailed(String(describing: decodingError))
      }
    } catch {
      throw ImportError.parsingFailed(error.localizedDescription)
    }
  }
  
  /// Encodes PropertyImportData for use in a URL (base64-encoded JSON)
  func encodePropertyDataForUrl(_ propertyData: PropertyImportData) throws -> String {
    let encoder = JSONEncoder()
    let data = try encoder.encode(propertyData)
    return data.base64EncodedString()
  }
  
  /// Saves the property to Firestore using the provided instance
  func savePropertyToFirestore(
    _ importData: PropertyImportData,
    firestore: Firestore
  ) async throws -> DocumentReference {
    let property = Property(
      title: importData.title,
      location: importData.location,
      link: importData.link,
      agency: importData.agency,
      price: importData.price,
      size: importData.size,
      bedrooms: importData.bedrooms,
      bathrooms: importData.bathrooms,
      type: importData.type,
      rating: .none // Default rating for imported properties
    )
    return try await firestore.setProperty(property)
  }
}
