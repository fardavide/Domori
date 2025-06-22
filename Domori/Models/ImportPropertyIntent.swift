import Foundation
import AppIntents
@preconcurrency import FirebaseFirestore

struct ImportPropertyIntent: AppIntent {
  static var title: LocalizedStringResource = "Import Property JSON"
  static var description: LocalizedStringResource = "Import property data from JSON and optionally open the Add Property screen"
  
  @Parameter(title: "JSON Payload", description: "JSON string containing property data")
  var jsonPayload: String
  
  @Parameter(title: "Open Editor", description: "Open Add Property screen with prefilled data", default: false)
  var openEditor: Bool
  
  func perform() async throws -> some IntentResult & OpensIntent & ReturnsValue<String> {
    let firestore = Firestore.firestore()
    let importService = PropertyImportService()
    do {
      let propertyData = try importService.parseAndValidate(jsonPayload)
      if openEditor {
        let encodedData = try importService.encodePropertyDataForUrl(propertyData)
        let url = URL(string: "domori://import-property?data=\(encodedData)")!
        return .result(value: "Opening Domori with imported property data", opensIntent: OpenURLIntent(url))
      } else {
        _ = try importService.savePropertyToFirestore(propertyData, firestore: firestore)
        return .result(value: "Property imported successfully")
      }
    } catch {
      throw ImportError.parsingFailed(error.localizedDescription)
    }
  }
}

// MARK: - Supporting Types

struct PropertyImportData: Codable {
  let title: String
  let location: String
  let link: String
  let agentContact: String
  let price: Double
  let size: Double
  let bedrooms: Int
  let bathrooms: Double
  let type: PropertyType
}

extension PropertyImportData {
  
  init(from c: any Decoder) throws {
    let container = try c.container(keyedBy: CodingKeys.self)
    self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Untitled Property"
    self.location = try container.decodeIfPresent(String.self, forKey: .location) ?? "Unknown Location"
    self.link = try container.decodeIfPresent(String.self, forKey: .link) ?? "Missing link"
    self.agentContact = try container.decodeIfPresent(String.self, forKey: .agentContact) ?? ""
    self.price = try container.decodeIfPresent(Double.self, forKey: .price) ?? 0
    self.size = try container.decodeIfPresent(Double.self, forKey: .size) ?? 0
    self.bedrooms = try container.decodeIfPresent(Int.self, forKey: .bedrooms) ?? 0
    self.bathrooms = try container.decodeIfPresent(Double.self, forKey: .bathrooms) ?? 0
    self.type = try container.decodeIfPresent(PropertyType.self, forKey: .type) ?? .house
  }
  
  enum CodingKeys: String, CodingKey {
    case title
    case location
    case link
    case agentContact
    case price
    case size
    case bedrooms
    case bathrooms
    case type
  }
}

enum ImportError: LocalizedError {
  case invalidJsonEncoding
  case jsonDecodingFailed(String)
  case parsingFailed(String)
  case firestoreError(String)
  
  var errorDescription: String? {
    switch self {
    case .invalidJsonEncoding:
      return "Invalid JSON encoding"
    case .jsonDecodingFailed(let details):
      return "JSON decoding failed: \(details)"
    case .parsingFailed(let details):
      return "Parsing failed: \(details)"
    case .firestoreError(let details):
      return "Firestore error: \(details)"
    }
  }
} 
