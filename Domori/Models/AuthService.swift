import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit

@MainActor
class AuthService: ObservableObject {
  @Published var isSignedIn = false
  @Published var currentUser: User?
  @Published var isLoading = false
  @Published var errorMessage: String?
  
  private var listener: NSObjectProtocol?
  private var currentNonce: String?
  
  init() {
    setupListener()
  }

  private func setupListener() {
    listener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
      DispatchQueue.main.async {
        self?.isSignedIn = user != nil
        self?.currentUser = user
      }
    }
  }
  
  deinit {
    Auth.auth().removeStateDidChangeListener(listener!)
  }
      
  func signInWithApple() async {
    isLoading = true
    errorMessage = nil
    
    do {
      let nonce = randomNonceString()
      currentNonce = nonce
      
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)
      
      let result = try await withCheckedThrowingContinuation { continuation in
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        let delegate = AppleSignInDelegate { result in
          continuation.resume(with: result)
        }
        authorizationController.delegate = delegate
        authorizationController.presentationContextProvider = delegate
        authorizationController.performRequests()
        
        // Store delegate to prevent deallocation
        objc_setAssociatedObject(authorizationController, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
      }
      
      guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential,
            let nonce = currentNonce else {
        throw AuthError.invalidCredential
      }
      
      guard let appleIDToken = appleIDCredential.identityToken else {
        throw AuthError.invalidToken
      }
      
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        throw AuthError.invalidToken
      }
      
      let credential = OAuthProvider.credential(
        withProviderID: "apple.com",
        idToken: idTokenString,
        rawNonce: nonce
      )
      
      let authResult = try await Auth.auth().signIn(with: credential)
      currentUser = authResult.user
      isSignedIn = true
      
    } catch {
      errorMessage = error.localizedDescription
    }
    
    isLoading = false
  }
  
  func signOut() {
    do {
      try Auth.auth().signOut()
      isSignedIn = false
      currentUser = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }
  
  // MARK: - Helper Methods
  
  private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
      let randoms: [UInt8] = (0 ..< 16).map { _ in
        var random: UInt8 = 0
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
        if errorCode != errSecSuccess {
          fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        return random
      }
      
      randoms.forEach { random in
        if remainingLength == 0 {
          return
        }
        
        if random < charset.count {
          result.append(charset[Int(random)])
          remainingLength -= 1
        }
      }
    }
    
    return result
  }
  
  private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      String(format: "%02x", $0)
    }.joined()
    
    return hashString
  }
}

// MARK: - Error Types

enum AuthError: LocalizedError {
  case invalidCredential
  case invalidToken
  
  var errorDescription: String? {
    switch self {
    case .invalidCredential:
      return "Invalid credential received from Apple"
    case .invalidToken:
      return "Invalid token received from Apple"
    }
  }
}

// MARK: - Apple Sign-In Delegate

private class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  private let completion: (Result<ASAuthorization, Error>) -> Void
  
  init(completion: @escaping (Result<ASAuthorization, Error>) -> Void) {
    self.completion = completion
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    completion(.success(authorization))
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    completion(.failure(error))
  }
  
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else {
      fatalError("No window available for Apple Sign-In")
    }
    return window
  }
} 
