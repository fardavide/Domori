import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

final class Application {
  
  static func openURL(_ url: URL) {
#if os(iOS)
    UIApplication.shared.open(url)
#elseif os(macOS)
    NSWorkspace.shared.open(url)
#endif
  }
}

final class Pasteboard {
  
  static func setString(_ string: String, type: PasteboardType) {
#if os(iOS)
    UIPasteboard.general.string = string
#elseif os(macOS)
    let nsType: NSPasteboard.PasteboardType
    switch type {
    case .string: nsType = .string
    }
    NSPasteboard.general.setString(string, forType: nsType)
#endif
  }
  
  enum PasteboardType {
    case string
  }
}
