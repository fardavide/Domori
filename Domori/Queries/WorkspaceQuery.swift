import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@Observable final class WorkspaceQuery {
  private(set) var current: Workspace?
  private(set) var required: Workspace!
  
  let currentSubject = CurrentValueSubject<Workspace?, Never>(nil)
  
  private let firestore = Firestore.firestore()
  private var cancellable: AnyCancellable?
  private var listener: ListenerRegistration?
  
  init(userQuery: UserQuery) {
    cancellable = userQuery.currentIdOrEmptySubject
      .sink { userId in
        self.listener?.remove()
        self.listener = self.firestore.collection(.workspaces)
          .whereField(.userIds, arrayContains: userId)
          .addSnapshotListener { snapshot, error in
            let allWorkspaces = snapshot?.documents.compactMap { try? $0.data(as: Workspace.self) } ?? []
            
            let workspace = switch allWorkspaces.count {
            case 0: try? self.createWorkspace(for: userId)
            case 1: allWorkspaces.first!
            default: self.ensureSingleWorkspace(all: allWorkspaces, for: userId)
            }
            
            self.currentSubject.send(workspace)
            self.current = workspace
            self.required = workspace
          }
      }
  }
  
  static func fake(workspace: Workspace) -> Self {
    .init(workspace: workspace)
  }
  
  private init(workspace: Workspace) {
    self.currentSubject.value = workspace
    self.current = workspace
    self.required = workspace
  }
  
  deinit {
    cancellable?.cancel()
    listener?.remove()
  }
  
  private func createWorkspace(for userId: String) throws -> Workspace {
    var newWorkspace = Workspace(userIds: [userId])
    let ref = try firestore.collection(.workspaces).addDocument(from: newWorkspace)
    newWorkspace.id = ref.documentID
    return newWorkspace
  }
  
  private func ensureSingleWorkspace(
    all workspaces: [Workspace],
    for userId: String
  ) -> Workspace {
    let sorted = workspaces.sorted { $0.userIds.count > $1.userIds.count }
    
    let batch = firestore.batch()
    for workspace in sorted.dropFirst() where workspace.id != nil {
      let ref = firestore.collection(.workspaces).document(workspace.id!)
      if workspace.userIds.count <= 1 {
        batch.deleteDocument(ref)
      } else {
        batch.updateData(
          [FirestoreField.userIds: FieldValue.arrayRemove([userId])],
          forDocument: ref
        )
      }
    }
    batch.commit()
    return sorted.first!
  }
}
