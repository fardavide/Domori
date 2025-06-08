import XCTest
import SwiftData
@testable import Domori

@MainActor
final class MigrationTests: XCTestCase {
    
    var container: ModelContainer!
    var context: ModelContext!
    
    override func setUp() async throws {
        // Create in-memory container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: PropertyListing.self, PropertyTag.self, configurations: config)
        context = container.mainContext
    }
    
    override func tearDown() async throws {
        container = nil
        context = nil
    }
  
  func testNoop() {
    
  }
}
