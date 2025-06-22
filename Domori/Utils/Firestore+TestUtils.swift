import FirebaseCore
import FirebaseFirestore

/// Test utilities for Firestore to provide isolated testing environments
extension Firestore {
  
  /// Creates a temporary Firestore instance for testing
  /// - Returns: A configured Firestore instance with test settings
  static func createTestFirestore() -> Firestore {
    let firestore = Firestore.firestore()
    firestore.clearPersistence()
    firestore.disableNetwork()
    return firestore
  }
  
  /// Creates a temporary Firestore instance for testing
  /// - Returns: A configured Firestore instance with test settings
  static func createTestFirestore() async throws -> Firestore {
    let firestore = Firestore.firestore()
    try await firestore.clearPersistence()
    try await firestore.disableNetwork()
    return firestore
  }
}
