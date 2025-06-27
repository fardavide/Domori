import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@Observable final class WorkspaceJoinRequestQuery {
  private let firestore = Firestore.firestore()
  private var userQuery: UserQuery
  private var workspaceQuery: WorkspaceQuery
  private var cancellable: AnyCancellable?
  private var listener: ListenerRegistration?
  
  private(set) var all: [WorkspaceJoinRequest] = []
  
  init(
    userQuery: UserQuery,
    workspaceQuery: WorkspaceQuery
  ) {
    self.userQuery = userQuery
    self.workspaceQuery = workspaceQuery
    
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
  
  func create(forWorkspaceId workspaceId: String) async throws {
    let request = WorkspaceJoinRequest(workspaceId: workspaceId, userId: userQuery.currentIdOrEmpty)
    try firestore.collection(.workspaceJoinRequests).addDocument(from: request)
  }
  
  func approve(joinRequestId requestId: String) async throws {
    guard let currentUserId = userQuery.current?.uid else {
      throw NSError(domain: "Not logged in", code: 0, userInfo: nil)
    }
    
    guard let currentWorkspaceId = workspaceQuery.current?.id else {
      throw NSError(domain: "No workspace", code: 0, userInfo: nil)
    }
    let requestRef = firestore.collection(.workspaceJoinRequests).document(requestId)
    let request = try await requestRef.getDocument(as: WorkspaceJoinRequest.self)
    if currentWorkspaceId != request.workspaceId {
      throw NSError(domain: "Not authorized to approve this request.", code: 0, userInfo: nil)
    }
    let inviteeUserId = request.userId
    
    let writeBatch = firestore.batch()
    writeBatch.updateData(
      [ FirestoreField.userIds: FieldValue.arrayUnion([inviteeUserId]) ],
      forDocument: firestore.collection(.workspaces).document(currentWorkspaceId)
    )
    for propertyRef in try await firestore.collection(.properties)
      .whereField(.userIds, arrayContains: currentUserId)
      .getDocuments().documents {
      writeBatch.updateData(
        [ FirestoreField.userIds: FieldValue.arrayUnion([inviteeUserId]) ],
        forDocument: propertyRef.reference
      )
    }
    for tagRef in try await firestore.collection(.tags)
      .whereField(.userIds, arrayContains: currentUserId)
      .getDocuments().documents {
      writeBatch.updateData(
        [ FirestoreField.userIds: FieldValue.arrayUnion([inviteeUserId]) ],
        forDocument: tagRef.reference
      )
    }
    writeBatch.deleteDocument(requestRef)
    try await writeBatch.commit()
  }
}
