import FirebaseFirestore
import SwiftUI

struct SettingsView: View {
  @Environment(\.firestore) private var firestore
  @EnvironmentObject private var authService: AuthService
  @State private var showingShareSheet = false
  
  @FirestoreQuery(
    collectionPath: FirestoreCollection.workspaces.rawValue,
    animation: .default
  )
  private var allWorkspaces: [Workspace]
  private var workspace: Workspace? {
    allWorkspaces.first
  }
  
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
      if let workspace = workspace {
        
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
          showingShareSheet = true
        }
      }
    }
    .onAppear {
      Task {
        // Create workspace if none
        try await firestore.getCurrentWorkspace()
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
      .sheet(isPresented: $showingShareSheet) {
        if let workspaceId = workspace?.id {
          let url = "domori://join-workspace?id=\(workspaceId)"
          ShareSheet(activityItems: [ "Join my workspace on Domori! \(url)" ])
        }
      }
    }
  }
}

struct ShareSheet: UIViewControllerRepresentable {
  let activityItems: [Any]
  
  func makeUIViewController(context: Context) -> UIActivityViewController {
    UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
  }
  
  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
  SettingsView()
    .environmentObject(AuthService())
}
