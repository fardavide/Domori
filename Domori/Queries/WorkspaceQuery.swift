import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@Observable final class WorkspaceQuery {
  private let firestore = Firestore.firestore()
  private var cancellable: AnyCancellable?
  private var listener: ListenerRegistration?
  
  private(set) var current: Workspace?
  
  let currentSubject = CurrentValueSubject<Workspace?, Never>(nil)
  
  init(userQuery: UserQuery) {
    cancellable = userQuery.currentIdOrEmptySubject
      .sink { userId in
        self.listener?.remove()
        self.listener = self.firestore.collection(.workspaces)
          .whereField(.userIds, arrayContains: userId)
          .addSnapshotListener { snapshot, error in
            let workspace = try? snapshot?.documents.first?.data(as: Workspace.self)
            self.currentSubject.send(workspace)
            self.current = workspace
          }
      }
  }
  
  deinit {
    cancellable?.cancel()
    listener?.remove()
  }
}
