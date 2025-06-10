import XCTest

/// Verifier for Add Property Screen - Contains only assertions
class AddPropertyVerifier {
    private let semantics: AddPropertySemantics
    
    init(semantics: AddPropertySemantics) {
        self.semantics = semantics
    }
    
    @discardableResult
    func verifyNavigationExists() -> AddPropertyVerifier {
        XCTAssertTrue(semantics.navigationBar.waitForExistence(timeout: 5), 
                     "Add Property screen should appear")
        return self
    }
    
    @discardableResult
    func verifyTitleFieldExists() -> AddPropertyVerifier {
        XCTAssertTrue(semantics.titleField.waitForExistence(timeout: 3), 
                     "Title field should exist")
        return self
    }
    
    @discardableResult
    func verifyLocationFieldExists() -> AddPropertyVerifier {
        XCTAssertTrue(semantics.locationField.exists, 
                     "Location field should exist")
        return self
    }
    
    @discardableResult
    func verifyLinkFieldExists() -> AddPropertyVerifier {
        XCTAssertTrue(semantics.linkField.exists, 
                     "Link field should exist")
        return self
    }
    
    @discardableResult
    func verifyNumericFieldsExist() -> AddPropertyVerifier {
        XCTAssertTrue(semantics.numericFields.count >= 2, 
                     "Price and Size fields should exist")
        return self
    }
    
    @discardableResult
    func verifyBedroomsStepperExists() -> AddPropertyVerifier {
        XCTAssertTrue(semantics.bedroomsStepper.exists, 
                     "Bedrooms stepper should be accessible")
        return self
    }
    
    @discardableResult
    func verifySaveButtonExists() -> AddPropertyVerifier {
        XCTAssertTrue(semantics.saveButton.exists, 
                     "Save button should exist")
        return self
    }
    
    @discardableResult
    func verifySaveButtonEnabled() -> AddPropertyVerifier {
        XCTAssertTrue(semantics.saveButton.isEnabled, 
                     "Save button should be enabled")
        return self
    }
    
    @discardableResult
    func verifyUpdateButtonEnabled() -> AddPropertyVerifier {
        XCTAssertTrue(semantics.updateButton.isEnabled, 
                     "Save button should be enabled")
        return self
    }
    
    @discardableResult
    func verifyCancelButtonExists() -> AddPropertyVerifier {
        XCTAssertTrue(semantics.cancelButton.exists, 
                     "Cancel button should exist")
        return self
    }
} 
