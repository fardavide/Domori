import XCTest

/// Robot for Add Property Screen - Contains actions using Semantics
class AddPropertyRobot {
  private let semantics: AddPropertySemantics
  
  init(app: XCUIApplication) {
    self.semantics = AddPropertySemantics(app: app)
  }
  
  // MARK: - Actions
  @discardableResult
  func waitForScreen() -> AddPropertyRobot {
    _ = semantics.navigationBar.waitForExistence(timeout: 5)
    return self
  }
  
  @discardableResult
  func fillTitle(_ title: String) -> AddPropertyRobot {
    semantics.titleField.clearAndTypeText(title)
    return self
  }
  
  @discardableResult
  func fillLocation(_ location: String) -> AddPropertyRobot {
    semantics.locationField.clearAndTypeText(location)
    return self
  }
  
  @discardableResult
  func fillLink(_ link: String) -> AddPropertyRobot {
    semantics.linkField.clearAndTypeText(link)
    return self
  }
  
  @discardableResult
  func fillAgentContact(_ contact: String) -> AddPropertyRobot {
    if semantics.agentContactField.exists {
      semantics.agentContactField.clearAndTypeText(contact)
    }
    return self
  }
  
  @discardableResult
  func fillPrice(_ price: String) -> AddPropertyRobot {
    semantics.priceField.clearAndTypeText(price)
    return self
  }
  
  @discardableResult
  func fillSize(_ size: String) -> AddPropertyRobot {
    semantics.sizeField.clearAndTypeText(size)
    return self
  }
  
  @discardableResult
  func setBedrooms(_ count: Int) -> AddPropertyRobot {
    // Reset to 0 first, then increment to target
    for _ in 0..<10 {
      if semantics.bedroomsDecrementButton.isEnabled {
        semantics.bedroomsDecrementButton.tap()
      }
    }
    
    // Increment to target count
    for _ in 0..<count {
      if semantics.bedroomsIncrementButton.isEnabled {
        semantics.bedroomsIncrementButton.tap()
      }
    }
    
    return self
  }
  
  @discardableResult
  func setBathrooms(_ count: Double) -> AddPropertyRobot {
    semantics.bathroomsPicker.tap()
    semantics.bathroomsOption(count).tap()
  
    return self
  }
  
  @discardableResult
  func setPropertyType(_ type: String) -> AddPropertyRobot {
    let typeButton = semantics.propertyTypeButton(type)
    if typeButton.exists {
      typeButton.tap()
      
      let targetOption = semantics.propertyTypeOption(type)
      if targetOption.exists && targetOption.isHittable {
        targetOption.tap()
      }
    }
    
    return self
  }
  
  @discardableResult
  func setPropertyRating(_ rating: String) -> AddPropertyRobot {
    let ratingMap = [
      "Not Rated": "none",
      "Excluded": "excluded",
      "Considering": "considering",
      "Good": "good",
      "Excellent": "excellent"
    ]
    
    if let ratingId = ratingMap[rating] {
      let ratingButton = semantics.ratingButton(ratingId)
      if ratingButton.exists && ratingButton.isHittable {
        ratingButton.tap()
      }
    }
    
    return self
  }
  
  @discardableResult
  func save() -> PropertiesListRobot {
    semantics.saveButton.tap()
    return PropertiesListRobot(app: semantics.app)
  }
  
  @discardableResult
  func update() -> PropertyDetailsRobot {
    semantics.updateButton.tap()
    return PropertyDetailsRobot(app: semantics.app)
  }
  
  @discardableResult
  func cancel() -> PropertiesListRobot {
    semantics.cancelButton.tap()
    return PropertiesListRobot(app: semantics.app)
  }
  
  // MARK: - Verify Method
  func verify(_ verifierAction: (AddPropertyVerifier) -> Void) -> AddPropertyRobot {
    let verifier = AddPropertyVerifier(semantics: semantics)
    verifierAction(verifier)
    return self
  }
}

// Add extension to get app reference
private extension AddPropertySemantics {
    var app: XCUIApplication {
        return XCUIApplication() // Get the shared app instance
    }
} 
