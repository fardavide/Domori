import FirebaseFirestore
import FirebaseAuth

enum FirestoreCollection: String {
#if DEBUG
  case properties = "test-properties"
  case tags = "test-tags"
  case workspaces = "test-workspaces"
  case workspaceJoinRequests = "test-workspace-join-requests"
#else
  case properties
  case tags
  case workspaces
  case workspaceJoinRequests = "workspace-join-requests"
#endif
}

enum FirestoreField: String {
  case userId
  case userIds
  case workspaceId
}

extension Firestore {
  
  private var currentUserId: String? {
    Auth.auth().currentUser?.uid
  }
  
  func getProperty(withId id: String) async throws -> Property {
    try await collection(.properties).document(id).getDocument(as: Property.self)
  }
  
  func setProperty(_ property: Property) async throws -> DocumentReference {
    var property = property
    property.userIds = try await getCurrentWorkspace().userIds
    if let id = property.id {
      var property = property
      property.updatedDate = Timestamp()
      let ref = collection(.properties).document(id)
      try ref.setData(from: property, merge: true)
      return ref
    } else {
      return try collection(.properties).addDocument(from: property)
    }
  }
  
  func deleteProperty(withId id: String) async throws {
    try await collection(.properties).document(id).delete()
  }
  
  func getTag(withId id: String) async throws -> PropertyTag {
    try await collection(.tags).document(id).getDocument(as: PropertyTag.self)
  }
  
  func setTag(_ tag: PropertyTag) async throws -> DocumentReference {
    var tag = tag
    tag.userIds = try await getCurrentWorkspace().userIds
    if let id = tag.id {
      let ref = collection(.tags).document(id)
      try ref.setData(from: tag, merge: true)
      return ref
    } else {
      return try collection(.tags).addDocument(from: tag)
    }
  }
  
  func deleteTag(withId id: String) async throws {
    try await collection(.tags).document(id).delete()
  }
  
  func getCurrentWorkspace() async throws -> Workspace {
    guard let userId = currentUserId else {
      throw NSError(domain: "Not logged in", code: 0, userInfo: nil)
    }
    let savedWorkspace = try? await collection(.workspaces)
      .whereField("userIds", arrayContains: userId)
      .getDocuments()
      .documents
      .first?.data(as: Workspace.self)
    
    if let workspace = savedWorkspace {
      return workspace
    } else {
      var newWorkspace = Workspace(userIds: [userId])
      let ref = try collection(.workspaces).addDocument(from: newWorkspace)
      newWorkspace.id = ref.documentID
      return newWorkspace
    }
  }
  
  func createWorkspaceJoinRequest(
    fromUserId userId: String,
    forWorkspaceId workspaceId: String
  ) async throws {
    let request = WorkspaceJoinRequest(workspaceId: workspaceId, userId: userId)
    try collection(.workspaceJoinRequests).addDocument(from: request)
    
    let currentWorkspace = try await getCurrentWorkspace()
    if let currentWorkspaceId = currentWorkspace.id {
      if currentWorkspace.userIds.count == 1 {
        try await collection(.workspaces).document(currentWorkspaceId).delete()
      } else {
        try await collection(.workspaces).document(currentWorkspaceId).updateData(
          ["userIds": FieldValue.arrayRemove([userId])]
        )
      }
    }
  }
  
  func approveWorkspaceJoinRequest(requestId: String) async throws {
    guard let currentUserId = currentUserId else {
      throw NSError(domain: "Not logged in", code: 0, userInfo: nil)
    }
    
    let currentWorkspace = try await getCurrentWorkspace()
    let requestRef = collection(.workspaceJoinRequests).document(requestId)
    let request = try await requestRef.getDocument(as: WorkspaceJoinRequest.self)
    if currentWorkspace.id != request.workspaceId {
      print("Not authorized to approve this request.")
      return
    }
    let inviteeUserId = request.userId
    
    let writeBatch = batch()
    writeBatch.updateData(
      ["userIds": FieldValue.arrayUnion([inviteeUserId])],
      forDocument: collection(.workspaces).document(currentWorkspace.id!)
    )
    for propertyRef in try await collection(.properties).whereField("userIds", arrayContains: currentUserId).getDocuments().documents {
      writeBatch.updateData(
        [ "userIds": FieldValue.arrayUnion([inviteeUserId]) ],
        forDocument: propertyRef.reference
      )
    }
    for tagRef in try await collection(.tags).whereField("userIds", arrayContains: currentUserId).getDocuments().documents {
      writeBatch.updateData(
        [ "userIds": FieldValue.arrayUnion([inviteeUserId]) ],
        forDocument: tagRef.reference
      )
    }
    writeBatch.deleteDocument(requestRef)
    try await writeBatch.commit()
  }
  
  func collection(_ collection: FirestoreCollection) -> CollectionReference {
    self.collection(collection.rawValue)
  }
}

extension CollectionReference {
  
  func whereField(_ field: FirestoreField, arrayContains value: Any) -> Query {
    whereField(field.rawValue, arrayContains: value)
  }
  
  func whereField(_ field: FirestoreField, isEqualTo value: Any) -> Query {
    whereField(field.rawValue, isEqualTo: value)
  }
}

extension Timestamp {  
  func formatted(date: Date.FormatStyle.DateStyle, time: Date.FormatStyle.TimeStyle) -> String {
    dateValue().formatted(date: date, time: time)
  }
}
