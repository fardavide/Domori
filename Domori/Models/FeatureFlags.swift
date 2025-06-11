final class FeatureFlags {
 
  private static var isDebugBuild: Bool {
#if DEBUG
    return true
#else
    return false
#endif
  }
  
  static let isShareEnabled = isDebugBuild
}
