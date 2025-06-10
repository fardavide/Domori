import XCTest

/// Semantics for Properties List Screen - Contains only UI element coordinates/locators
struct PropertiesListSemantics {
  private let app: XCUIApplication
  
  init(app: XCUIApplication) {
    self.app = app
  }
  
  // MARK: - Navigation Elements
  var navigationBar: XCUIElement {
    app.navigationBars["Properties"]
  }
  
  var addButton: XCUIElement {
    navigationBar.buttons["plus"]
  }
  
  // MARK: - Content Elements
  var propertiesCollection: XCUIElement {
    app.collectionViews.firstMatch
  }
  
  var searchField: XCUIElement {
    app.textFields["Search properties..."]
  }
  
  var sortButton: XCUIElement {
    app.buttons["Sort"]
  }
  
  // MARK: - Property Cells
  func propertyCell(at index: Int) -> XCUIElement {
    propertiesCollection.cells.element(boundBy: index)
  }
  
  var firstPropertyCell: XCUIElement {
    propertyCell(at: 0)
  }
  
  func propertyWith(title: String) -> XCUIElement {
    app.staticTexts[title]
  }
  
  func propertyWith(location: String) -> XCUIElement {
    app.staticTexts[location]
  }
  
  func propertyWith(price: String) -> XCUIElement {
    app.staticTexts.containing(NSPredicate(format: "label CONTAINS '\(price)'")).firstMatch
  }
  
  var allPropertyCells: XCUIElementQuery {
    propertiesCollection.cells
  }
}
