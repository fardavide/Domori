import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@Observable final class PropertyQuery {
  private(set) var all: [Property] = []
  
  private let firestore = Firestore.firestore()
  private let workspaceQuery: WorkspaceQuery
  private var cancellable: AnyCancellable?
  private var listener: ListenerRegistration?
  
  init(
    userQuery: UserQuery,
    workspaceQuery: WorkspaceQuery,
  ) {
    self.workspaceQuery = workspaceQuery
    
    cancellable = userQuery.currentIdOrEmptySubject
      .sink { userId in
        self.listener?.remove()
        self.listener = self.firestore.collection(.properties)
          .whereField(.userIds, arrayContains: userId)
          .addSnapshotListener { snapshot, error in
            if let properties = snapshot?.documents {
              self.all = properties.compactMap { try? $0.data(as: Property.self) }
            } else {
              self.all = []
            }
          }
      }
  }
  
  deinit {
    cancellable?.cancel()
    listener?.remove()
  }
  
  func get(withId id: String) async throws -> Property? {
    try await firestore.collection(.properties).document(id).getDocument(as: Property.self)
  }
  
  func set(_ property: Property) async throws -> DocumentReference {
    var property = property
    property.userIds = workspaceQuery.required.userIds
    if let id = property.id {
      var property = property
      property.updatedDate = Timestamp()
      let ref = firestore.collection(.properties).document(id)
      try ref.setData(from: property, merge: true)
      return ref
    } else {
      return try firestore.collection(.properties).addDocument(from: property)
    }
  }
  
  func delete(withId id: String) async throws {
    try await firestore.collection(.properties).document(id).delete()
  }
}
