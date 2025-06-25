import SwiftUI
import FirebaseCore
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
        .environmentObject(urlHandler)
        .environmentObject(authService)
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

// MARK: - URL Handler

class UrlHandler: ObservableObject {
  @Published var importData: PropertyImportData?
  @Published var shouldShowImportView = false
  
  func handleUrl(_ url: URL) {
    guard url.scheme == "domori" else { return }
    
    if url.host == "import-property" {
      handleImportPropertyUrl(url)
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
}

private final class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    // Only configure Firebase if not in test mode
    if !DomoriApp.isTest && !DomoriApp.isUiTest {
      FirebaseApp.configure()
    }
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
