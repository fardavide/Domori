import FirebaseFirestore

enum FirestoreCollection: String {
#if DEBUG
  case properties = "test-properties"
  case tags = "test-tags"
#else
  case properties
  case tags
#endif
}

extension Firestore {
  
  func getProperty(withId id: String) async throws -> Property {
    try await collection(.properties).document(id).getDocument(as: Property.self)
  }
  
  func setProperty(_ property: Property) throws -> DocumentReference {
    if let id = property.id {
      var property = property
      property.updatedDate = Timestamp()
      let ref = collection(.properties).document(id)
      try ref.setData(from: property)
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
  
  func setTag(_ tag: PropertyTag) throws -> DocumentReference {
    if let id = tag.id {
      let ref = collection(.tags).document(id)
      try ref.setData(from: tag)
      return ref
    } else {
      return try collection(.tags).addDocument(from: tag)
    }
  }
  
  func deleteTag(withId id: String) async throws {
    try await collection(.tags).document(id).delete()
  }
  
  private func collection(_ collection: FirestoreCollection) -> CollectionReference {
    self.collection(collection.rawValue)
  }
}

extension Timestamp {  
  func formatted(date: Date.FormatStyle.DateStyle, time: Date.FormatStyle.TimeStyle) -> String {
    dateValue().formatted(date: date, time: time)
  }
}
