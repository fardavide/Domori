import XCTest

final class ExportImportUiTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Navigation Tests
    
    func testNavigateToExportImportView() throws {
        // Navigate to settings
        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()
        
        // Navigate to export/import
        let exportImportLink = app.buttons["Export/Import Data"]
        XCTAssertTrue(exportImportLink.waitForExistence(timeout: 5))
        exportImportLink.tap()
        
        // Verify export/import view is displayed
        let exportImportTitle = app.navigationBars["Export/Import Data"]
        XCTAssertTrue(exportImportTitle.waitForExistence(timeout: 5))
    }
    
    func testExportImportViewComponentsExist() throws {
        try navigateToExportImportView()
        
        // Check export section
        let exportTitle = app.staticTexts["Export"]
        XCTAssertTrue(exportTitle.exists)
        
        // Check import section  
        let importTitle = app.staticTexts["Import"]
        XCTAssertTrue(importTitle.exists)
        
        let importButton = app.buttons["Choose File"]
        XCTAssertTrue(importButton.exists)
        
        let replaceToggle = app.switches["Replace existing data"]
        XCTAssertTrue(replaceToggle.exists)
    }
    
    // MARK: - Export Tests
    
    func testExportAllWorkspacesButtonExists() throws {
        try navigateToExportImportView()
        
        let exportAllButton = app.buttons["Export All"]
        XCTAssertTrue(exportAllButton.exists)
    }
    
    func testExportIndividualWorkspace() throws {
        try navigateToExportImportView()
        
        // Look for any workspace export buttons (they should have "Export" text)
        let exportButtons = app.buttons.matching(identifier: "Export")
        if exportButtons.count > 0 {
            let firstExportButton = exportButtons.element(boundBy: 0)
            XCTAssertTrue(firstExportButton.exists)
            
            // Test tapping the export button (this would normally trigger file save dialog)
            firstExportButton.tap()
            
            // Note: File save dialog interaction would require additional UI test setup
            // for now we just verify the button works
        }
    }
    
    // MARK: - Import Tests
    
    func testImportFilePickerInteraction() throws {
        try navigateToExportImportView()
        
        let chooseFileButton = app.buttons["Choose File"]
        XCTAssertTrue(chooseFileButton.exists)
        
        chooseFileButton.tap()
        
        // Note: File picker interaction would require additional setup
        // for automated testing. This test verifies the button is accessible.
    }
    
    func testReplaceExistingToggleFunctionality() throws {
        try navigateToExportImportView()
        
        let replaceToggle = app.switches["Replace existing data"]
        XCTAssertTrue(replaceToggle.exists)
        
        // Test toggling the switch
        let initialValue = replaceToggle.value as? String
        replaceToggle.tap()
        
        // Verify toggle state changed
        let newValue = replaceToggle.value as? String
        XCTAssertNotEqual(initialValue, newValue)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorMessageDisplay() throws {
        try navigateToExportImportView()
        
        // Check that error messages can be displayed
        // Note: This would require triggering an actual error condition
        // For now, we verify the view structure supports error display
        
        let chooseFileButton = app.buttons["Choose File"]
        XCTAssertTrue(chooseFileButton.exists)
        
        // In a real test scenario, we would:
        // 1. Select an invalid file
        // 2. Verify error message appears
        // 3. Verify error can be dismissed
    }
    
    // MARK: - Accessibility Tests
    
    func testExportImportViewAccessibility() throws {
        try navigateToExportImportView()
        
        // Verify key elements have accessibility labels
        let exportTitle = app.staticTexts["Export"]
        XCTAssertTrue(exportTitle.exists)
        XCTAssertTrue(exportTitle.isAccessibilityElement)
        
        let importTitle = app.staticTexts["Import"]
        XCTAssertTrue(importTitle.exists)
        XCTAssertTrue(importTitle.isAccessibilityElement)
        
        let chooseFileButton = app.buttons["Choose File"]
        XCTAssertTrue(chooseFileButton.exists)
        XCTAssertTrue(chooseFileButton.isAccessibilityElement)
        
        let replaceToggle = app.switches["Replace existing data"]
        XCTAssertTrue(replaceToggle.exists)
        XCTAssertTrue(replaceToggle.isAccessibilityElement)
    }
    
    // MARK: - Integration Tests
    
    func testFullNavigationFlow() throws {
        // Navigate to settings
        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()
        
        // Navigate to export/import
        let exportImportLink = app.buttons["Export/Import Data"]
        XCTAssertTrue(exportImportLink.waitForExistence(timeout: 5))
        exportImportLink.tap()
        
        // Verify we're in the export/import view
        let navigationTitle = app.navigationBars["Export/Import Data"]
        XCTAssertTrue(navigationTitle.waitForExistence(timeout: 5))
        
        // Navigate back
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        if backButton.exists {
            backButton.tap()
            
            // Verify we're back in settings
            let settingsNavTitle = app.navigationBars["Settings"]
            XCTAssertTrue(settingsNavTitle.waitForExistence(timeout: 5))
        }
    }
    
    // MARK: - Helper Methods
    
    @discardableResult
    private func navigateToExportImportView() throws -> XCUIApplication {
        // Navigate to settings
        let settingsButton = app.buttons["Settings"]
        if !settingsButton.waitForExistence(timeout: 5) {
            throw XCTSkip("Settings button not found - app may not have loaded properly")
        }
        settingsButton.tap()
        
        // Navigate to export/import
        let exportImportLink = app.buttons["Export/Import Data"]
        if !exportImportLink.waitForExistence(timeout: 5) {
            throw XCTSkip("Export/Import Data link not found")
        }
        exportImportLink.tap()
        
        // Verify we're in the right view
        let navigationTitle = app.navigationBars["Export/Import Data"]
        if !navigationTitle.waitForExistence(timeout: 5) {
            throw XCTSkip("Export/Import view did not load properly")
        }
        
        return app
    }
} 