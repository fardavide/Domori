import XCTest

/// Robot for Property Details Screen - Contains actions using Semantics
class PropertyDetailsRobot {
    private let semantics: PropertyDetailsSemantics
    
    init(app: XCUIApplication) {
        self.semantics = PropertyDetailsSemantics(app: app)
    }
    
    // MARK: - Actions
    @discardableResult
    func waitForScreen() -> PropertyDetailsRobot {
        _ = semantics.scrollView.waitForExistence(timeout: 5)
        return self
    }
    
    @discardableResult
    func tapEdit() -> AddPropertyRobot {
        if semantics.editButton.exists {
            semantics.editButton.tap()
        } else {
            semantics.navigationEditButton.tap()
        }
        return AddPropertyRobot(app: semantics.app)
    }
    
    @discardableResult
    func tapAddTag() -> PropertyDetailsRobot {
        semantics.addTagButton.tap()
        return self
    }
    
    @discardableResult
    func fillTagName(_ name: String) -> PropertyDetailsRobot {
        semantics.tagNameField.clearAndTypeText(name)
        return self
    }
    
    @discardableResult
    func selectTagRating(_ rating: String) -> PropertyDetailsRobot {
        let ratingMap = [
            "Not Rated": "none",
            "Excluded": "excluded",
            "Considering": "considering", 
            "Good": "good",
            "Excellent": "excellent"
        ]
        
        if let ratingId = ratingMap[rating] {
            let ratingButton = semantics.tagRatingButton(ratingId)
            if ratingButton.exists && ratingButton.isHittable {
                ratingButton.tap()
            }
        }
        
        return self
    }
    
    @discardableResult
    func createTag() -> PropertyDetailsRobot {
        semantics.createTagButton.tap()
        _ = semantics.scrollView.waitForExistence(timeout: 3)
        return self
    }
    
    @discardableResult
    func cancelTagCreation() -> PropertyDetailsRobot {
        semantics.cancelTagButton.tap()
        return self
    }
    
    @discardableResult
    func addTag(name: String, rating: String) -> PropertyDetailsRobot {
        return self
            .tapAddTag()
            .verify { $0.verifyAddTagsScreenExists() }
            .fillTagName(name)
            .selectTagRating(rating)
            .verify { $0.verifyCreateTagButtonEnabled() }
            .createTag()
    }
    
    @discardableResult
    func navigateBack() -> PropertiesListRobot {
        if semantics.backButton.exists {
            semantics.backButton.tap()
        } else {
            // Try swipe gesture as fallback
            semantics.scrollView.swipeRight()
        }
        
        return PropertiesListRobot(app: semantics.app)
    }
    
    // MARK: - Verify Method
    func verify(_ verifierAction: (PropertyDetailsVerifier) -> Void) -> PropertyDetailsRobot {
        let verifier = PropertyDetailsVerifier(semantics: semantics)
        verifierAction(verifier)
        return self
    }
}

// Add extension to get app reference
private extension PropertyDetailsSemantics {
    var app: XCUIApplication {
        return XCUIApplication() // Get the shared app instance
    }
}

 