import XCTest

/// Verifier for Property Details Screen - Contains only assertions
class PropertyDetailsVerifier {
    private let semantics: PropertyDetailsSemantics
    
    init(semantics: PropertyDetailsSemantics) {
        self.semantics = semantics
    }
    
    @discardableResult
    func verifyDetailViewExists() -> PropertyDetailsVerifier {
        XCTAssertTrue(semantics.scrollView.waitForExistence(timeout: 5), 
                     "Property detail view should appear")
        return self
    }
    
    @discardableResult
    func verifyTitle(_ title: String) -> PropertyDetailsVerifier {
        XCTAssertTrue(semantics.titleText(title).exists, 
                     "Property detail should show title '\(title)'")
        return self
    }
    
    @discardableResult
    func verifyLocation(_ location: String) -> PropertyDetailsVerifier {
        XCTAssertTrue(semantics.locationTextContaining(location).exists, 
                     "Property detail should show location containing '\(location)'")
        return self
    }
    
    @discardableResult
    func verifyPrice(_ price: String) -> PropertyDetailsVerifier {
        XCTAssertTrue(semantics.priceTextContaining(price).exists, 
                     "Property detail should show price containing '\(price)'")
        return self
    }
    
    @discardableResult
    func verifySize(_ size: String) -> PropertyDetailsVerifier {
        XCTAssertTrue(semantics.sizeTextContaining(size).exists, 
                     "Property detail should show size containing '\(size)'")
        return self
    }
    
    @discardableResult
    func verifyBedrooms(_ count: Int) -> PropertyDetailsVerifier {
        XCTAssertTrue(semantics.bedroomsText(count).exists, 
                     "Property detail should show \(count) beds")
        return self
    }
    
    @discardableResult
    func verifyBathrooms(_ count: Double) -> PropertyDetailsVerifier {
        XCTAssertTrue(semantics.bathroomsText(count).exists,
                     "Property detail should show \(count) bathrooms")
        return self
    }
    
    @discardableResult
    func verifyTagsSection() -> PropertyDetailsVerifier {
        XCTAssertTrue(semantics.tagsHeader.exists, 
                     "Tags section should be visible")
        return self
    }
    
    @discardableResult
    func verifyTagExists(_ tagName: String) -> PropertyDetailsVerifier {
        XCTAssertTrue(semantics.tagElement(tagName).exists, 
                     "Property should have tag '\(tagName)'")
        return self
    }
    
    @discardableResult
    func verifyAddTagButtonExists() -> PropertyDetailsVerifier {
        XCTAssertTrue(semantics.addTagButton.exists, 
                     "Add Tag button should exist")
        return self
    }
    
    @discardableResult
    func verifyEditButtonExists() -> PropertyDetailsVerifier {
        let editExists = semantics.editButton.exists || semantics.navigationEditButton.exists
        XCTAssertTrue(editExists, "Edit button should exist")
        return self
    }
    
    @discardableResult
    func verifyAddTagsScreenExists() -> PropertyDetailsVerifier {
        XCTAssertTrue(semantics.addTagsNavigationBar.waitForExistence(timeout: 5), 
                     "Add Tags screen should appear")
        return self
    }
    
    @discardableResult
    func verifyTagNameFieldExists() -> PropertyDetailsVerifier {
        XCTAssertTrue(semantics.tagNameField.exists, 
                     "Tag name field should exist")
        return self
    }
    
    @discardableResult
    func verifyCreateTagButtonEnabled() -> PropertyDetailsVerifier {
        XCTAssertTrue(semantics.createTagButton.exists && semantics.createTagButton.isEnabled, 
                     "Create Tag button should be enabled")
        return self
    }
} 
