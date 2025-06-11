import Foundation

final class FeatureFlags {
  static let shared = FeatureFlags()
  
  var isShareEnabled: Bool {
    true
  }
  
  var isCloudKitAvailable: Bool {
#if targetEnvironment(simulator)
    return true
#else
    return FileManager.default.ubiquityIdentityToken != nil
#endif
  }
  
  private var isDebugBuild: Bool {
#if DEBUG
    return true
#else
    return false
#endif
  }
}
