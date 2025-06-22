import FirebaseFirestore

enum FirestoreCollection: String {
  case properties
  case tags
}

extension Firestore {
  func collection(_ collection: FirestoreCollection) -> CollectionReference {
    self.collection(collection.rawValue)
  }
}
