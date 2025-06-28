import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@Observable final class TagQuery {
  private(set) var all: [PropertyTag] = []
  
  private let firestore = Firestore.firestore()
  private let workspaceQuery: WorkspaceQuery
  private var cancellable: AnyCancellable?
  private var listener: ListenerRegistration?
  
  init(
    userQuery: UserQuery,
    workspaceQuery: WorkspaceQuery
  ) {
    self.workspaceQuery = workspaceQuery
    
    cancellable = userQuery.currentIdOrEmptySubject
      .sink { userId in
        self.listener?.remove()
        self.listener = self.firestore.collection(.tags)
          .whereField(.userIds, arrayContains: userId)
          .addSnapshotListener { snapshot, error in
            if let tags = snapshot?.documents {
              self.all = tags.compactMap { try? $0.data(as: PropertyTag.self) }
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
  
  func set(_ tag: PropertyTag) async throws -> DocumentReference {
    var tag = tag
    tag.userIds = workspaceQuery.required.userIds
    if let id = tag.id {
      let ref = firestore.collection(.tags).document(id)
      try ref.setData(from: tag, merge: true)
      return ref
    } else {
      return try firestore.collection(.tags).addDocument(from: tag)
    }
  }
}
