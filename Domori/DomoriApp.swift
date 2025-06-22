import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct DomoriApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
  static let isTest = ProcessInfo.processInfo.arguments.contains("test")
  static let isUiTest = ProcessInfo.processInfo.arguments.contains("uitest")
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.firestore, createFirestoreInstance())
    }
    
#if os(macOS)
    Settings {
      SettingsView()
    }
#endif
  }
  
  private func createFirestoreInstance() -> Firestore {
    if DomoriApp.isUiTest {
      Firestore.createTestFirestore()
    } else {
      Firestore.firestore()
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
