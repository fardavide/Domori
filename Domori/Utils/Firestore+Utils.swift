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
