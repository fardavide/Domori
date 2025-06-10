import XCTest

/// Semantics for Add Property Screen - Contains only UI element coordinates/locators
struct AddPropertySemantics {
  private let app: XCUIApplication
  
  init(app: XCUIApplication) {
    self.app = app
  }
  
  // MARK: - Navigation Elements
  var navigationBar: XCUIElement {
    app.navigationBars["Add Property"]
  }
  
  var cancelButton: XCUIElement {
    app.buttons["Cancel"]
  }
  
  var saveButton: XCUIElement {
    app.buttons["Save"]
  }
  
  var updateButton: XCUIElement {
    app.buttons["Update"]
  }
  
  // MARK: - Form Fields
  var titleField: XCUIElement {
    app.textFields["Title (Required)"]
  }
  
  var locationField: XCUIElement {
    app.textFields["Location (Required)"]
  }
  
  var linkField: XCUIElement {
    app.textFields["Link (Required)"]
  }
  
  var agentContactField: XCUIElement {
    app.textFields["Agent Contact (Phone)"]
  }
  
  // MARK: - Numeric Fields
  var numericFields: XCUIElementQuery {
    app.textFields.matching(NSPredicate(format: "placeholderValue == '0'"))
  }
  
  var priceField: XCUIElement {
    numericFields.element(boundBy: 0)
  }
  
  var sizeField: XCUIElement {
    numericFields.element(boundBy: 1)
  }
  
  // MARK: - Bedrooms Stepper  
  var bedroomsStepper: XCUIElement {
    app.steppers.firstMatch // Get the first stepper element on the screen
  }
  
  var bedroomsDecrementButton: XCUIElement {
    app.buttons.matching(NSPredicate(format: "label CONTAINS 'Decrement'")).firstMatch
  }
  
  var bedroomsIncrementButton: XCUIElement {
    app.buttons.matching(NSPredicate(format: "label CONTAINS 'Increment'")).firstMatch
  }
  
  // MARK: - Bathrooms Picker  
  var bathroomsPicker: XCUIElement {
    app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Bathrooms'")).firstMatch
  }
  
  func bathroomsOption(_ count: Double) -> XCUIElement {
    let countString = count == floor(count) ? "\(Int(count))" : String(format: "%.1f", count)
    return app.buttons[countString]
  }
  
  // MARK: - Property Type Picker
  func propertyTypeButton(_ type: String) -> XCUIElement {
    app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '\(type)' OR label CONTAINS[c] 'Property Type'")).firstMatch
  }
  
  func propertyTypeOption(_ type: String) -> XCUIElement {
    app.buttons[type]
  }
  
  // MARK: - Rating Buttons
  func ratingButton(_ ratingId: String) -> XCUIElement {
    app.buttons["rating_\(ratingId)"]
  }
}
