import XCTest

// MARK: - XCUIElement Extensions

extension XCUIElement {
  /// Clear existing text and type new text in a text field
  func clearAndTypeText(_ text: String) {
    // Ensure field is visible and hittable
    guard exists && isHittable else { return }
    XCTAssert(exists && isHittable, "Element not visible or not hittable")
    
    // Tap to focus
    tap()
    
    // Use CMD+A to select all text, then type new text to replace
    typeKey("a", modifierFlags: .command)
    
    // Type the new text (this will replace selected text)
    typeText(text)
  }
}
