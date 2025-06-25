import FirebaseFirestore
import SwiftUI

struct SettingsView: View {
  @Environment(\.firestore) private var firestore
  @EnvironmentObject private var authService: AuthService
  
  @FirestoreQuery(
    collectionPath: FirestoreCollection.workspaces.rawValue,
    animation: .default
  )
  private var allWorkspaces: [Workspace]
  
  @FirestoreQuery(
    collectionPath: FirestoreCollection.workspaceJoinRequests.rawValue,
    animation: .default
  )
  private var allJoinRequests: [WorkspaceJoinRequest]
  
  var currentUserSection: some View {
    Section("Current user") {
      if authService.isSignedIn {
        HStack {
          Text("Signed in as")
          Spacer()
          Text(authService.currentUser?.email ?? "Apple ID")
            .foregroundColor(.secondary)
        }
        
        Button("Sign Out") {
          authService.signOut()
        }
        .foregroundColor(.red)
      } else {
        Button(action: {
          Task {
            await authService.signInWithApple()
          }
        }) {
          HStack {
            Image(systemName: "applelogo")
            Text("Sign in with Apple")
          }
        }
        .disabled(authService.isLoading)
        
        if authService.isLoading {
          HStack {
            ProgressView()
              .scaleEffect(0.8)
            Text("Signing in...")
              .foregroundColor(.secondary)
          }
        }
      }
      
      if let errorMessage = authService.errorMessage {
        Text(errorMessage)
          .foregroundColor(.red)
          .font(.caption)
      }
    }
  }
  
  var workspaceSection: some View {
    Section("Workspaces") {
      let workspace = allWorkspaces.first ?? Workspace(userIds: [])
      
      if workspace.userIds.count == 1 {
        Text("You're the only one in this workspace.")
      } else {
        Text("There are \(workspace.userIds.count) users in this workspace.")
      }
      
      if let requestId = allJoinRequests.first?.id {
        Text("An user requested to join this workspace.")
        Button("Accept") {
          Task {
            do {
               try await firestore.approveWorkspaceJoinRequest(requestId: requestId)
            } catch {
              print("Could not approve join request: \(error)")
            }
          }
        }
      }
      Button("Invite users") {
        Task {
          // TODO create invite to be shared
          // "Join my workspace on Domori! domori://join-workspace?id=\(workspace.id)"
        }
      }
    }
  }
  
  var appInformationSection: some View {
    Section("App Information") {
      
      HStack {
        Text("Version")
        Spacer()
        Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
          .foregroundColor(.secondary)
      }
      
      HStack {
        Text("Build")
        Spacer()
        Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)
          .foregroundColor(.secondary)
      }
    }
  }
  
  var body: some View {
    NavigationView {
      Form {
        currentUserSection
        workspaceSection
        appInformationSection
      }
      .navigationTitle("Settings")
    }
  }
}

#Preview {
  SettingsView()
    .environmentObject(AuthService())
}
