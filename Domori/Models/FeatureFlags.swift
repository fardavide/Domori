final class FeatureFlags {
  static let shared = FeatureFlags()
  
  var isShareEnabled: Bool {
    isDebugBuild
  }
  
  private var isDebugBuild: Bool {
#if DEBUG
    return true
#else
    return false
#endif
  }
}
