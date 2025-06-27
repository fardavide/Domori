import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@Observable final class TagQuery {
  private let firestore = Firestore.firestore()
  private var cancellable: AnyCancellable?
  private var listener: ListenerRegistration?
  
  private(set) var all: [PropertyTag] = []
  
  init(userQuery: UserQuery) {
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
}
