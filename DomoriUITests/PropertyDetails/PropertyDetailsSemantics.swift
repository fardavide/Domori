import XCTest

/// Semantics for Property Details Screen - Contains only UI element coordinates/locators
struct PropertyDetailsSemantics {
  private let app: XCUIApplication
  
  init(app: XCUIApplication) {
    self.app = app
  }
  
  // MARK: - Navigation Elements
  var navigationBar: XCUIElement {
    app.navigationBars.firstMatch
  }
  
  var backButton: XCUIElement {
    navigationBar.buttons.element(boundBy: 0)
  }
  
  var editButton: XCUIElement {
    app.buttons["Edit"]
  }
  
  var navigationEditButton: XCUIElement {
    navigationBar.buttons["Edit"]
  }
  
  // MARK: - Content Elements
  var scrollView: XCUIElement {
    app.scrollViews.firstMatch
  }
  
  // MARK: - Property Information
  func titleText(_ title: String) -> XCUIElement {
    app.staticTexts[title]
  }
  
  func locationTextContaining(_ location: String) -> XCUIElement {
    app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] '\(location)'")).firstMatch
  }
  
  func priceTextContaining(_ price: String) -> XCUIElement {
    app.staticTexts.containing(NSPredicate(format: "label CONTAINS '\(price)'")).firstMatch
  }
  
  func sizeTextContaining(_ size: String) -> XCUIElement {
    app.staticTexts.containing(NSPredicate(format: "label CONTAINS '\(size)'")).firstMatch
  }
  
  func bedroomsText(_ count: Int) -> XCUIElement {
    app.staticTexts.containing(NSPredicate(format: "label CONTAINS '\(count)' AND label CONTAINS 'bed'")).firstMatch
  }
  
  func bathroomsText(_ count: Double) -> XCUIElement {
    let countString = count == floor(count) ? "\(Int(count))" : String(format: "%.1f", count)
    return app.staticTexts.containing(NSPredicate(format: "label CONTAINS '\(countString)' AND label CONTAINS 'bath'")).firstMatch
  }
  
  // MARK: - Tags Section
  var tagsHeader: XCUIElement {
    app.staticTexts["Tags"]
  }
  
  var addTagButton: XCUIElement {
    app.buttons["Add Tag"]
  }
  
  func tagElement(_ tagName: String) -> XCUIElement {
    app.staticTexts[tagName]
  }
  
  // MARK: - Add Tags Screen Elements
  var addTagsNavigationBar: XCUIElement {
    app.navigationBars["Add Tags"]
  }
  
  var tagNameField: XCUIElement {
    app.textFields["Enter tag name"]
  }
  
  var createTagButton: XCUIElement {
    app.buttons["Create Tag"]
  }
  
  var cancelTagButton: XCUIElement {
    app.buttons["Cancel"]
  }
  
  func tagRatingButton(_ ratingId: String) -> XCUIElement {
    app.buttons["rating_\(ratingId)"]
  }
}
