import XCTest

/// Robot for Properties List Screen - Contains actions using Semantics
class PropertiesListRobot {
    private let semantics: PropertiesListSemantics
    
    init(app: XCUIApplication) {
        self.semantics = PropertiesListSemantics(app: app)
    }
    
    // MARK: - Actions
    @discardableResult
    func waitForScreen() -> PropertiesListRobot {
        _ = semantics.navigationBar.waitForExistence(timeout: 10)
        return self
    }
    
    @discardableResult
    func tapAdd() -> AddPropertyRobot {
        semantics.addButton.tap()
        return AddPropertyRobot(app: semantics.app)
    }
    
    @discardableResult
    func tapProperty(at index: Int) -> PropertyDetailsRobot {
        semantics.propertyCell(at: index).tap()
        return PropertyDetailsRobot(app: semantics.app)
    }
    
    @discardableResult
    func tapFirstProperty() -> PropertyDetailsRobot {
        semantics.firstPropertyCell.tap()
        return PropertyDetailsRobot(app: semantics.app)
    }
    
    @discardableResult
    func tapSearch() -> PropertiesListRobot {
        semantics.searchField.tap()
        return self
    }
    
    @discardableResult
    func tapSort() -> PropertiesListRobot {
        semantics.sortButton.tap()
        return self
    }
    
    // MARK: - Verify Method
    func verify(_ verifierAction: (PropertiesListVerifier) -> Void) -> PropertiesListRobot {
        let verifier = PropertiesListVerifier(semantics: semantics)
        verifierAction(verifier)
        return self
    }
}

// Add extension to get app reference
private extension PropertiesListSemantics {
    var app: XCUIApplication {
        return XCUIApplication() // Get the shared app instance
    }
} 