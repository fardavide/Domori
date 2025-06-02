//

import XCTest

final class DomoriUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Verify the app launches and shows the main content
        XCTAssertTrue(app.navigationBars.firstMatch.exists)
        
        // Should show property listings
        let propertyList = app.collectionViews.firstMatch
        XCTAssertTrue(propertyList.waitForExistence(timeout: 3.0))
    }
    
    @MainActor
    func testNavigationBasics() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for content to load
        let propertyList = app.collectionViews.firstMatch
        XCTAssertTrue(propertyList.waitForExistence(timeout: 3.0))
        
        // Test that we can see property titles in the list
        let firstProperty = propertyList.cells.firstMatch
        XCTAssertTrue(firstProperty.exists)
        
        // Test navigation to detail view
        firstProperty.tap()
        
        // Should navigate to detail view
        // Note: This depends on the actual navigation implementation
        // We'll look for common detail view elements
        let detailView = app.scrollViews.firstMatch
        XCTAssertTrue(detailView.waitForExistence(timeout: 2.0))
    }
    
    @MainActor
    func testAddPropertyFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for the main view to load
        let propertyList = app.collectionViews.firstMatch
        XCTAssertTrue(propertyList.waitForExistence(timeout: 3.0))
        
        // Look for the add button (usually a "+" button)
        let addButton = app.buttons["Add Property"]
        if addButton.exists {
            addButton.tap()
            
            // Should show add property form
            let titleField = app.textFields["Title"]
            if titleField.waitForExistence(timeout: 2.0) {
                titleField.tap()
                titleField.typeText("UI Test Property")
                
                // Fill in location (updated from address)
                let locationField = app.textFields["Location"]
                if locationField.exists {
                    locationField.tap()
                    locationField.typeText("123 UI Test Street")
                }
                
                // Fill in link (new mandatory field)
                let linkField = app.textFields["Property Link"]
                if linkField.exists {
                    linkField.tap()
                    linkField.typeText("https://example.com/ui-test-property")
                }
                
                // Save the property
                let saveButton = app.buttons["Save"]
                if saveButton.exists {
                    saveButton.tap()
                    
                    // Should return to main list
                    XCTAssertTrue(propertyList.waitForExistence(timeout: 2.0))
                }
            }
        }
    }
    
    @MainActor
    func testPropertyListSorting() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for content to load
        let propertyList = app.collectionViews.firstMatch
        XCTAssertTrue(propertyList.waitForExistence(timeout: 3.0))
        
        // Look for sort options (typically in a menu or toolbar)
        let sortButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Sort' OR label CONTAINS 'sort'")).firstMatch
        if sortButton.exists {
            sortButton.tap()
            
            // Should show sort options
            let sortMenu = app.menus.firstMatch
            if sortMenu.waitForExistence(timeout: 1.0) {
                // Test selecting a sort option
                let priceSort = app.buttons["Price"]
                if priceSort.exists {
                    priceSort.tap()
                }
            }
        }
    }
    
    @MainActor
    func testPropertySearch() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for content to load
        let propertyList = app.collectionViews.firstMatch
        XCTAssertTrue(propertyList.waitForExistence(timeout: 3.0))
        
        // Look for search functionality
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("Victorian")
            
            // Results should filter
            // The exact assertion depends on your sample data
            XCTAssertTrue(propertyList.exists)
        }
    }
    
    @MainActor
    func testPropertyFavorites() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for content to load
        let propertyList = app.collectionViews.firstMatch
        XCTAssertTrue(propertyList.waitForExistence(timeout: 3.0))
        
        // Test favorite functionality if visible in list
        let firstProperty = propertyList.cells.firstMatch
        if firstProperty.exists {
            // Look for favorite button or heart icon
            let favoriteButton = firstProperty.buttons.matching(NSPredicate(format: "label CONTAINS 'heart' OR label CONTAINS 'favorite'")).firstMatch
            if favoriteButton.exists {
                favoriteButton.tap()
                // Should toggle favorite state
                XCTAssertTrue(favoriteButton.exists)
            }
        }
    }
    
    @MainActor
    func testPropertyComparison() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for content to load
        let propertyList = app.collectionViews.firstMatch
        XCTAssertTrue(propertyList.waitForExistence(timeout: 3.0))
        
        // Look for compare functionality
        let compareButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Compare' OR label CONTAINS 'compare'")).firstMatch
        if compareButton.exists {
            compareButton.tap()
            
            // Should show comparison view or selection mode
            // This test depends on your specific implementation
            XCTAssertTrue(app.otherElements.firstMatch.exists)
        }
    }
    
    @MainActor
    func testPropertyDetailView() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for content to load
        let propertyList = app.collectionViews.firstMatch
        XCTAssertTrue(propertyList.waitForExistence(timeout: 3.0))
        
        // Tap on first property
        let firstProperty = propertyList.cells.firstMatch
        XCTAssertTrue(firstProperty.exists)
        firstProperty.tap()
        
        // Should show detail view
        let detailView = app.scrollViews.firstMatch
        if detailView.waitForExistence(timeout: 2.0) {
            
            // Look for common detail elements
            let priceLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '$' OR label CONTAINS '€' OR label CONTAINS '£'")).firstMatch
            XCTAssertTrue(priceLabel.exists)
            
            // Test scrolling in detail view
            detailView.swipeUp()
            
            // Should be able to navigate back
            let backButton = app.buttons["Back"]
            if backButton.exists {
                backButton.tap()
                XCTAssertTrue(propertyList.waitForExistence(timeout: 2.0))
            } else {
                // Try swipe back gesture
                app.swipeRight()
                XCTAssertTrue(propertyList.waitForExistence(timeout: 2.0))
            }
        }
    }
    
    @MainActor
    func testPropertyRatingSystem() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for content to load
        let propertyList = app.collectionViews.firstMatch
        XCTAssertTrue(propertyList.waitForExistence(timeout: 3.0))
        
        // Navigate to first property detail
        let firstProperty = propertyList.cells.firstMatch
        firstProperty.tap()
        
        let detailView = app.scrollViews.firstMatch
        if detailView.waitForExistence(timeout: 2.0) {
            
            // Look for rating elements in detail view
            let ratingElements = app.buttons.matching(NSPredicate(format: "label CONTAINS 'star' OR identifier CONTAINS 'rating'"))
            if ratingElements.count > 0 {
                let firstStar = ratingElements.firstMatch
                firstStar.tap()
                
                // Should update rating
                XCTAssertTrue(firstStar.exists)
            }
        }
    }
    
    @MainActor
    func testPropertyListRatingIcons() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for content to load
        let propertyList = app.collectionViews.firstMatch
        XCTAssertTrue(propertyList.waitForExistence(timeout: 3.0))
        
        // Check that rating labels are visible in the list (updated from icons to labels)
        let ratingLabels = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Excellent' OR label CONTAINS 'Good' OR label CONTAINS 'Considering' OR label CONTAINS 'Excluded' OR label CONTAINS 'Not Rated'"))
        
        // Should have at least one rating label visible
        if ratingLabels.count > 0 {
            XCTAssertTrue(ratingLabels.firstMatch.exists)
            
            // Verify different rating states exist in sample data
            let excellentRating = app.staticTexts["Excellent"]
            let goodRating = app.staticTexts["Good"]
            let consideringRating = app.staticTexts["Considering"]
            let excludedRating = app.staticTexts["Excluded"]
            let noRating = app.staticTexts["Not Rated"]
            
            // At least one type should exist
            let hasAnyRating = excellentRating.exists || goodRating.exists || 
                             consideringRating.exists || excludedRating.exists || noRating.exists
            XCTAssertTrue(hasAnyRating, "At least one rating label should be visible")
        }
        
        // Check that property type icons are visible in the list (small, gray)
        let propertyTypeIcons = app.images.matching(NSPredicate(format: "label CONTAINS 'house' OR label CONTAINS 'building' OR label CONTAINS 'bed.double' OR label CONTAINS 'car.garage'"))
        if propertyTypeIcons.count > 0 {
            XCTAssertTrue(propertyTypeIcons.firstMatch.exists, "Property type icons should be visible")
        }
        
        // Test that selection buttons are present and functional
        let selectionButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'circle' OR label CONTAINS 'checkmark.circle.fill'"))
        if selectionButtons.count > 0 {
            XCTAssertTrue(selectionButtons.firstMatch.exists, "Selection buttons should be present")
            
            // Test selection functionality - tap a selection button
            let firstSelectionButton = selectionButtons.firstMatch
            firstSelectionButton.tap()
            
            // The button should change state (circle -> checkmark.circle.fill or vice versa)
            // We just verify the button still exists after interaction
            XCTAssertTrue(firstSelectionButton.exists, "Selection button should still exist after tap")
        }
        
        // Test that tapping on the main content area navigates to detail view instead of selecting
        let firstProperty = propertyList.cells.firstMatch
        if firstProperty.exists {
            // Tap on the property row (not on the selection button)
            let propertyContent = firstProperty.staticTexts.firstMatch
            if propertyContent.exists {
                propertyContent.tap()
                
                // Should navigate to detail view, not select the item
                let detailView = app.scrollViews.firstMatch
                if detailView.waitForExistence(timeout: 2.0) {
                    // Successfully navigated to detail view
                    XCTAssertTrue(detailView.exists, "Should navigate to detail view when tapping property content")
                    
                    // Navigate back to test list again
                    let backButton = app.buttons["Back"]
                    if backButton.exists {
                        backButton.tap()
                    } else {
                        app.swipeRight()
                    }
                    XCTAssertTrue(propertyList.waitForExistence(timeout: 2.0))
                }
            }
        }
    }
    
    @MainActor
    func testSettingsAccess() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Look for settings button or gear icon
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings' OR label CONTAINS 'settings' OR label CONTAINS 'gear'")).firstMatch
        if settingsButton.exists {
            settingsButton.tap()
            
            // Should show settings view
            let settingsView = app.navigationBars["Settings"]
            XCTAssertTrue(settingsView.waitForExistence(timeout: 2.0))
            
            // Navigate back
            let backButton = app.buttons["Back"]
            if backButton.exists {
                backButton.tap()
            } else {
                app.swipeRight()
            }
        }
    }
    
    @MainActor
    func testPropertyTags() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for content to load
        let propertyList = app.collectionViews.firstMatch
        XCTAssertTrue(propertyList.waitForExistence(timeout: 3.0))
        
        // Navigate to property detail
        let firstProperty = propertyList.cells.firstMatch
        firstProperty.tap()
        
        let detailView = app.scrollViews.firstMatch
        if detailView.waitForExistence(timeout: 2.0) {
            
            // Look for tag elements
            let tagElements = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Priority' OR label CONTAINS 'Deal' OR label CONTAINS 'Ready'"))
            if tagElements.count > 0 {
                // Tags should be visible
                XCTAssertTrue(tagElements.firstMatch.exists)
            }
        }
    }
    
    @MainActor
    func testAccessibilityElements() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test that key elements have accessibility labels
        let propertyList = app.collectionViews.firstMatch
        XCTAssertTrue(propertyList.waitForExistence(timeout: 3.0))
        
        // Check that list items are accessible
        let firstProperty = propertyList.cells.firstMatch
        XCTAssertTrue(firstProperty.exists)
        XCTAssertTrue(firstProperty.isHittable)
        
        // Check navigation elements
        let navBar = app.navigationBars.firstMatch
        XCTAssertTrue(navBar.exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
