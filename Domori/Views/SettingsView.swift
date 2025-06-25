import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var authService: AuthService
  
  var authenticationSection: some View {
    Section("Authentication") {
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
        authenticationSection
        appInformationSection
      }
      .navigationTitle("Settings")
    }
  }
}

#Preview {
  SettingsView()
}
