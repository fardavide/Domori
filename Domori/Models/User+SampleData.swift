import FirebaseAuth

extension User {
  
  static var sampleApple: UserInfo {
    FakeUser(
      providerID: "apple.com",
      displayName: "Test Apple",
      email: "test@icloud.com"
    )
  }
  
  static var sampleEmail: UserInfo {
    FakeUser(
      providerID: "email",
      displayName: nil,
      email: "test@email.com"
    )
  }
}

final class FakeUser: NSObject, UserInfo {
  var providerID: String
  var displayName: String?
  var email: String?
  
  var uid: String = "sampleUID"
  var photoURL: URL? = nil
  var phoneNumber: String? = nil
  
  init(providerID: String, displayName: String?, email: String) {
    self.providerID = providerID
    self.displayName = displayName
    self.email = email
  }
}
