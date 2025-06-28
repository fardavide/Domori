import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct SettingsView: View {
  @Environment(AuthService.self) private var authService
  
  @Environment(WorkspaceQuery.self) private var workspaceQuery
  private var workspace: Workspace? { workspaceQuery.current }
  
  @Environment(WorkspaceJoinRequestQuery.self) private var joinRequestQuery
  private var joinRequests: [WorkspaceJoinRequest] { joinRequestQuery.all }
  
  @State private var showingShareSheet = false
  
  var currentUserSection: some View {
    Section("Current user") {
      if let user = authService.currentUser {
        userCard(for: user)
        Button("Sign Out") {
          authService.signOut()
        }
        .foregroundColor(.red)
      } else {
        Button("Sign in with Apple", systemImage: "applelogo") {
          Task {
            await authService.signInWithApple()
          }
        }
        .disabled(authService.isLoading)
        if FeatureFlags.shared.isPswSignInEnabled {
          Button("Sign in with email", systemImage: "at") {
            // TODO
          }
          .disabled(authService.isLoading)
        }
        
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
  
  private func userCard(for user: UserInfo) -> some View {
    VStack(alignment: .trailing) {
      HStack {
        Text("Signed in as - \(user.providerID)")
        Spacer()
        Text(user.displayName ?? user.email ?? "Unknown user")
          .foregroundColor(.secondary)
      }
      if let email = user.email, user.displayName != nil {
        Text(email)
          .foregroundColor(.secondary)
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
        
        if let requestId = joinRequests.first?.id {
          Text("An user requested to join this workspace.")
          Button("Accept") {
            Task {
              do {
                try await joinRequestQuery.approve(joinRequestId: requestId)
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
        if workspaceQuery.current != nil {
          workspaceSection
        }
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

#Preview("Apple user") {
  let authService = AuthService.preview(currentUser: User.sampleApple)
  SettingsView()
    .environment(authService)
    .previewQueries(authService: authService)
}

#Preview("Email user") {
  let authService = AuthService.preview(currentUser: User.sampleEmail)
  SettingsView()
    .environment(authService)
    .previewQueries(authService: authService)
}

#Preview("No user") {
  let authService = AuthService.preview(currentUser: nil)
  SettingsView()
    .environment(authService)
    .previewQueries(authService: authService)
}
