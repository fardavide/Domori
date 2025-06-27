import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@Observable final class PropertyQuery {
  private let firestore = Firestore.firestore()
  private var cancellable: AnyCancellable?
  private var listener: ListenerRegistration?
  
  private(set) var all: [Property] = []
  
  init(userQuery: UserQuery) {
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
}
