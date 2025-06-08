import Foundation
import SwiftData
import SwiftUI
import CloudKit

@Observable
final class UserManager {
    private(set) var currentUser: User?
    private(set) var isSignedIn: Bool = false
    
    static let shared = UserManager()
    
    private init() {
        // Try to automatically sign in with iCloud
        checkiCloudAccountStatus()
    }
    
    // MARK: - iCloud Authentication
    
    private func checkiCloudAccountStatus() {
        Task {
            do {
                let accountStatus = try await CKContainer.default().accountStatus()
                await MainActor.run {
                    switch accountStatus {
                    case .available:
                        // User is signed into iCloud, get their user record
                        fetchUserIdentity()
                    case .noAccount:
                        print("UserManager: No iCloud account found")
                        self.handleiCloudUnavailable()
                    case .restricted:
                        print("UserManager: iCloud account restricted")
                        self.handleiCloudUnavailable()
                    case .couldNotDetermine:
                        print("UserManager: Could not determine iCloud status")
                        self.handleiCloudUnavailable()
                    case .temporarilyUnavailable:
                        print("UserManager: iCloud temporarily unavailable")
                        self.handleiCloudUnavailable()
                    @unknown default:
                        print("UserManager: Unknown iCloud account status")
                        self.handleiCloudUnavailable()
                    }
                }
            } catch {
                print("UserManager: Error checking iCloud account status - \(error.localizedDescription)")
                await MainActor.run {
                    self.handleiCloudUnavailable()
                }
            }
        }
    }
    
    private func fetchUserIdentity() {
        Task {
            do {
                let userRecordID = try await CKContainer.default().userRecordID()
                let userIdentity = try await CKContainer.default().userIdentity(forUserRecordID: userRecordID)
                
                await MainActor.run {
                    if let identity = userIdentity, let nameComponents = identity.nameComponents {
                        let name = PersonNameComponentsFormatter().string(from: nameComponents)
                        let email = identity.lookupInfo?.emailAddress ?? "\(userRecordID.recordName)@icloud.com"
                        
                        // Auto-sign in with iCloud credentials
                        autoSignInWithiCloud(name: name.isEmpty ? "iCloud User" : name, email: email)
                    } else {
                        // Use recordName as fallback
                        let fallbackEmail = "\(userRecordID.recordName)@icloud.com"
                        autoSignInWithiCloud(name: "iCloud User", email: fallbackEmail)
                    }
                }
            } catch {
                print("UserManager: Error fetching user identity - \(error.localizedDescription)")
                await MainActor.run {
                    self.handleiCloudUnavailable()
                }
            }
        }
    }
    
    private func autoSignInWithiCloud(name: String, email: String) {
        // For automatic iCloud sign-in, we need access to ModelContext
        // We'll set the user info and let the app handle context-dependent operations
        DispatchQueue.main.async {
            self.currentUser = User(name: name, email: email)
            self.isSignedIn = true
            self.saveCurrentUser()
            print("UserManager: Auto-signed in with iCloud - \(name) (\(email))")
        }
    }
    
    private func handleiCloudUnavailable() {
        // Try to load a previously stored user, or signal that no user is available
        loadCurrentUser()
        if !isSignedIn {
            // Signal that iCloud authentication has completed (unsuccessfully)
            // The MainAppView will create a default user
            print("UserManager: iCloud unavailable, will use default user")
        }
    }
    
    // MARK: - User Authentication
    
    func signIn(name: String, email: String, context: ModelContext) {
        // Check if user already exists  
        let userEmail = email
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { user in
                user.email == userEmail
            }
        )
        
        do {
            let existingUsers = try context.fetch(descriptor)
            if let existingUser = existingUsers.first {
                // Use existing user and ensure they have a personal workspace
                existingUser.createPersonalWorkspace(context: context)
                try context.save()
                currentUser = existingUser
            } else {
                // Create new user
                let newUser = User(name: name, email: email)
                context.insert(newUser)
                try context.save()
                
                // Create personal workspace for new user
                newUser.createPersonalWorkspace(context: context)
                try context.save()
                
                currentUser = newUser
            }
            
            isSignedIn = true
            saveCurrentUser()
            
        } catch {
            print("UserManager: Error signing in user - \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        currentUser = nil
        isSignedIn = false
        clearCurrentUser()
    }
    
    func updateUserInfo(name: String, context: ModelContext) {
        guard let currentUser = currentUser else { return }
        
        currentUser.name = name
        currentUser.updatedDate = Date()
        
        do {
            try context.save()
            saveCurrentUser()
        } catch {
            print("UserManager: Error updating user info - \(error.localizedDescription)")
        }
    }
    
    // MARK: - Persistence
    
    private func saveCurrentUser() {
        guard let user = currentUser else { return }
        
        UserDefaults.standard.set(user.id, forKey: "currentUserId")
        UserDefaults.standard.set(user.name, forKey: "currentUserName")
        UserDefaults.standard.set(user.email, forKey: "currentUserEmail")
        UserDefaults.standard.set(true, forKey: "isSignedIn")
    }
    
    private func loadCurrentUser() {
        let isSignedInStored = UserDefaults.standard.bool(forKey: "isSignedIn")
        guard isSignedInStored else { return }
        
        guard let userId = UserDefaults.standard.string(forKey: "currentUserId"),
              let userName = UserDefaults.standard.string(forKey: "currentUserName"),
              let userEmail = UserDefaults.standard.string(forKey: "currentUserEmail") else {
            return
        }
        
        // Create a temporary user object for UI purposes
        // The actual user object will be fetched from context when needed
        let tempUser = User(name: userName, email: userEmail)
        tempUser.id = userId
        currentUser = tempUser
        isSignedIn = true
    }
    
    private func clearCurrentUser() {
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        UserDefaults.standard.removeObject(forKey: "currentUserName")
        UserDefaults.standard.removeObject(forKey: "currentUserEmail")
        UserDefaults.standard.set(false, forKey: "isSignedIn")
    }
    
    // MARK: - Helper Methods
    
    func getCurrentUser(context: ModelContext) -> User? {
        guard let currentUser = currentUser else { return nil }
        
        // Fetch the actual user from context
        let userId = currentUser.id
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { user in
                user.id == userId
            }
        )
        
        do {
            let users = try context.fetch(descriptor)
            return users.first
        } catch {
            print("UserManager: Error fetching current user - \(error.localizedDescription)")
            return nil
        }
    }
    
    var requiresSignIn: Bool {
        return !isSignedIn || currentUser == nil
    }
    
    // MARK: - Public Methods for Fallback User Creation
    
    func createDefaultUser() {
        let defaultUser = User(name: "Local User", email: "local@device.local")
        currentUser = defaultUser
        isSignedIn = true
        saveCurrentUser()
        print("UserManager: Created default local user")
    }
} 