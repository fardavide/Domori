import XCTest

/// Verifier for Properties List Screen - Contains only assertions
class PropertiesListVerifier {
  private let semantics: PropertiesListSemantics
  
  init(semantics: PropertiesListSemantics) {
    self.semantics = semantics
  }
  
  @discardableResult
  func verifyNavigationExists() -> PropertiesListVerifier {
    XCTAssertTrue(semantics.navigationBar.waitForExistence(timeout: 10),
                  "Properties navigation should appear")
    return self
  }
  
  @discardableResult
  func verifyAddButtonExists() -> PropertiesListVerifier {
    XCTAssertTrue(semantics.addButton.exists, "Add button should exist")
    return self
  }
  
  @discardableResult
  func verifyPropertyExists(title: String) -> PropertiesListVerifier {
    XCTAssertTrue(
      semantics.propertyWith(title: title).waitForExistence(timeout: 5),
      "Property with title '\(title)' should exist in list"
    )
    return self
  }
  
  @discardableResult
  func verifyPropertyExists(location: String) -> PropertiesListVerifier {
    XCTAssertTrue(
      semantics.propertyWith(location: location).waitForExistence(timeout: 1),
      "Property with location '\(location)' should exist in list"
    )
    return self
  }
  
  @discardableResult
  func verifyPropertyExists(price: String) -> PropertiesListVerifier {
    XCTAssertTrue(
      semantics.propertyWith(price: price).exists,
      "Property should display price containing '\(price)'"
    )
    return self
  }
  
  @discardableResult
  func verifyPropertiesCount(_ count: Int) -> PropertiesListVerifier {
    // Allow for loading time
    Thread.sleep(forTimeInterval: 1.0)
    let actualCount = semantics.allPropertyCells.count
    XCTAssertEqual(actualCount, count,
                   "Should have \(count) properties, but found \(actualCount)")
    return self
  }
  
  @discardableResult
  func verifyPropertyAtIndexExists(_ index: Int) -> PropertiesListVerifier {
    XCTAssertTrue(semantics.propertyCell(at: index).waitForExistence(timeout: 5),
                  "Property at index \(index) should exist")
    return self
  }
  
  @discardableResult
  func verifySearchFieldExists() -> PropertiesListVerifier {
    XCTAssertTrue(semantics.searchField.waitForExistence(timeout: 3),
                  "Search field should be available")
    return self
  }
}
