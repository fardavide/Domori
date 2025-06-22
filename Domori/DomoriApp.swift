import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct DomoriApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
  private static let isTest = ProcessInfo.processInfo.arguments.contains("test")
  
  var body: some Scene {
    WindowGroup {
      if DomoriApp.isTest {
        Text("Running unit tests")
      } else {
        ContentView()
          .environment(\.firestore, Firestore.firestore())
      }
    }
    
#if os(macOS)
    Settings {
      SettingsView()
    }
#endif
  }
}

private final class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
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
