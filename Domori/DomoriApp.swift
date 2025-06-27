import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import AppIntents

@main
struct DomoriApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
  @StateObject private var urlHandler = UrlHandler()
  @StateObject private var authService = AuthService()
  static let isTest = ProcessInfo.processInfo.arguments.contains("test")
  static let isUiTest = ProcessInfo.processInfo.arguments.contains("uitest")
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.firestore, Firestore.firestore())
        .environmentObject(authService)
        .environmentObject(urlHandler)
        .environment(delegate.propertyQuery)
        .environment(delegate.tagQuery)
        .environment(delegate.userQuery)
        .environment(delegate.workspaceJoinRequestQuery)
        .environment(delegate.workspaceQuery)
        .onOpenURL { url in
          urlHandler.handleUrl(url)
        }
    }
    
#if os(macOS)
    Settings {
      SettingsView()
        .environmentObject(authService)
    }
#endif
  }
}

class UrlHandler: ObservableObject {
  private let firestore = Firestore.firestore()
  private let auth = Auth.auth()
  
  @Published var importData: PropertyImportData?
  @Published var shouldShowImportView = false
  
  func handleUrl(_ url: URL) {
    guard url.scheme == "domori" else { return }
    
    switch url.host {
    case "import-property": handleImportPropertyUrl(url)
    case "join-workspace": handleJoinWorkspaceUrl(url)
    default:
      print("Unsupported URL host: \(url.host ?? "(unknown)")")
    }
  }
  
  private func handleImportPropertyUrl(_ url: URL) {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let dataParam = components.queryItems?.first(where: { $0.name == "data" })?.value,
          let data = Data(base64Encoded: dataParam) else {
      print("Invalid import URL format")
      return
    }
    
    do {
      let decoder = JSONDecoder()
      let importData = try decoder.decode(PropertyImportData.self, from: data)
      self.importData = importData
      self.shouldShowImportView = true
    } catch {
      print("Failed to decode import data: \(error)")
    }
  }
  
  private func handleJoinWorkspaceUrl(_ url: URL) {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let workspaceId = components.queryItems?.first(where: { $0.name == "id" })?.value else {
      print("Invalid join workspace URL format")
      return
    }
    
    Task {
      do {
        try await firestore.createWorkspaceJoinRequest(
          fromUserId: auth.currentUser!.uid,
          forWorkspaceId: workspaceId
        )
      } catch {
        print("Failed to join workspace: \(error)")
      }
    }
  }
}

private final class AppDelegate: NSObject, UIApplicationDelegate {
  
  private var _propertyQuery: PropertyQuery?
  var propertyQuery: PropertyQuery { _propertyQuery! }
  
  private var _tagQuery: TagQuery?
  var tagQuery: TagQuery { _tagQuery! }
  
  private var _userQuery: UserQuery?
  var userQuery: UserQuery { _userQuery! }
  
  private var _workspaceJoinRequestQuery: WorkspaceJoinRequestQuery?
  var workspaceJoinRequestQuery: WorkspaceJoinRequestQuery { _workspaceJoinRequestQuery! }
  
  private var _workspaceQuery: WorkspaceQuery?
  var workspaceQuery: WorkspaceQuery { _workspaceQuery! }
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    // Only configure Firebase if not in test mode
    if !DomoriApp.isTest && !DomoriApp.isUiTest {
      FirebaseApp.configure()
    }
    _userQuery = UserQuery()
    _propertyQuery = PropertyQuery(userQuery: userQuery)
    _tagQuery = TagQuery(userQuery: userQuery)
    _workspaceQuery = WorkspaceQuery(userQuery: userQuery)
    _workspaceJoinRequestQuery = WorkspaceJoinRequestQuery(workspaceQuery: workspaceQuery)
    return true
  }
}

private struct FirestoreKey: EnvironmentKey {
  static let defaultValue = Firestore.firestore()
}

extension EnvironmentValues {
  var firestore: Firestore {
    get { self[FirestoreKey.self] }
    set { self[FirestoreKey.self] = newValue }
  }
}

// MARK: - App Intents Configuration

extension DomoriApp {
  static var appIntents: [any AppIntent] {
    [ImportPropertyIntent()]
  }
}
