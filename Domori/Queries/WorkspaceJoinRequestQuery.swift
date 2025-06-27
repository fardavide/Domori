import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@Observable final class WorkspaceJoinRequestQuery {
  private let firestore = Firestore.firestore()
  private var cancellable: AnyCancellable?
  private var listener: ListenerRegistration?
  
  private(set) var all: [WorkspaceJoinRequest] = []
  
  init(workspaceQuery: WorkspaceQuery) {
    cancellable = workspaceQuery.currentSubject
      .sink { workspace in
        self.listener?.remove()
        self.listener = self.firestore.collection(.workspaceJoinRequests)
          .whereField(.workspaceId, isEqualTo: workspace?.id ?? "")
          .addSnapshotListener { snapshot, error in
            if let requests = snapshot?.documents {
              self.all = requests.compactMap { try? $0.data(as: WorkspaceJoinRequest.self) }
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
