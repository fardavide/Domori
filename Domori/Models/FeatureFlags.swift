final class FeatureFlags {
  static let shared = FeatureFlags()
  
  var isPswSignInEnabled: Bool {
    false
  }
  
  private var isDebugBuild: Bool {
#if DEBUG
    return true
#else
    return false
#endif
  }
}
