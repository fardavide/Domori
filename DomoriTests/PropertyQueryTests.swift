import Testing
import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI
@testable import Domori

@MainActor
struct PropertyQueryTests {
  
  @Test func testPropertyCreation() async throws {
    let scenario = Scenario()
    
    // Create a test property
    var property = Property(
      title: "Test Property",
      location: "123 Test Street",
      link: "https://example.com/test",
      agency: nil,
      price: 500000,
      size: 100,
      bedrooms: 2,
      bathrooms: 1.5,
      type: .house,
      rating: .good
    )
    
    // Add to Firestore
    let docRef = try await scenario.sut.set(property)
    
    // Fetch and verify the property was created correctly
    let fetchedProperty = try await scenario.sut.get(withId: docRef.documentID)
    #expect(fetchedProperty != nil)
    guard let fetchedProperty else { return }
    
    // Update Firestore manager fields
    property.id = fetchedProperty.id
    property.createdDate = fetchedProperty.createdDate
    property.updatedDate = fetchedProperty.updatedDate
    property.userIds = [scenario.user.uid]
    
    #expect(fetchedProperty == property)
  }
  
  @Test func testPropertyWithTags() async throws {
    let scenario = Scenario()
    
    // Create tags first
    let tag1 = PropertyTag(name: "Great Location", rating: .good)
    let tag2 = PropertyTag(name: "Needs Work", rating: .considering)
    
    let tag1Ref = try await scenario.tagQuery.set(tag1)
    let tag2Ref = try await scenario.tagQuery.set(tag2)
    
    // Create a test property with tag references
    var property = Property(
      title: "Test Property with Tags",
      location: "456 Tag Street",
      link: "https://example.com/tags",
      agency: nil,
      price: 750000,
      size: 150,
      bedrooms: 3,
      bathrooms: 2.0,
      type: .condo,
      rating: .excellent
    )
    
    // Add tag IDs to property
    property.tagIds = [tag1Ref.documentID, tag2Ref.documentID]
    
    // Add property to Firestore
    let propertyRef = try await scenario.sut.set(property)
    
    // Fetch and verify
    let fetchedProperty = try await scenario.sut.get(withId: propertyRef.documentID)
    #expect(fetchedProperty != nil)
    guard let fetchedProperty else { return }
    
    #expect(fetchedProperty.tagIds.count == 2)
    #expect(fetchedProperty.tagIds.contains(tag1Ref.documentID))
    #expect(fetchedProperty.tagIds.contains(tag2Ref.documentID))
  }
  
  private struct Scenario {
    let sut: PropertyQuery
    let tagQuery: TagQuery
    let user = User.sampleEmail
    
    init() {
      let userQuery = UserQuery(authService: .fake(currentUser: user))
      let workspaceQuery = WorkspaceQuery.fake(workspace: Workspace.sample(forUserId: user.uid))
      sut = .init(
        userQuery: userQuery,
        workspaceQuery: workspaceQuery
      )
      tagQuery = .init(
        userQuery: userQuery,
        workspaceQuery: workspaceQuery
      )
    }
  }
}
