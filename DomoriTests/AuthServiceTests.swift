import Testing
import FirebaseAuth
import SwiftUI
@testable import Domori

@MainActor
struct AuthServiceTests {
  
  @Test func testAuthServiceInitialization() async throws {
    let authService = AuthService()
    
    // Initially should not be signed in
    #expect(authService.currentUser == nil)
    #expect(authService.isLoading == false)
    #expect(authService.errorMessage == nil)
  }
  
  @Test func testAuthServiceSignOut() async throws {
    let authService = AuthService()
    
    // Test sign out when not signed in (should not throw)
    authService.signOut()
    
    #expect(authService.currentUser == nil)
  }
    
  @Test func testAuthErrorLocalization() async throws {
    let invalidCredentialError = AuthError.invalidCredential
    let invalidTokenError = AuthError.invalidToken
    
    #expect(invalidCredentialError.errorDescription == "Invalid credential received from Apple")
    #expect(invalidTokenError.errorDescription == "Invalid token received from Apple")
  }
} 
