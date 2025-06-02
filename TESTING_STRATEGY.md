# 🧪 Testing Strategy Guide for Domori

## 🎯 Core Testing Principles

### 1. **FAIL HARD, NOT SILENT**
- ❌ **Never allow tests to fail silently**
- ✅ **Always use explicit assertions with clear error messages**
- ✅ **Fail immediately when critical operations don't work**

### 2. **Robust Navigation Testing**
- ❌ **Don't assume navigation works** - verify it explicitly
- ✅ **Use multiple navigation methods with fallbacks**
- ✅ **Verify final screen state after navigation**
- ✅ **Provide detailed debugging information on navigation failures**

### 3. **State Verification**
- ❌ **Don't assume UI elements exist** - check explicitly
- ✅ **Verify expected UI state before proceeding**
- ✅ **Use timeouts appropriately but fail if expectations aren't met**

---

## 🔧 **UI Test Requirements**

### Navigation Testing Pattern:
```swift
private func navigateBackToMainScreen(in app: XCUIApplication, from location: String) {
    print("🔙 Navigating back to main screen from \(location)")
    
    let mainScreenNavBar = app.navigationBars["Properties"]
    
    // Check if we're already on main screen
    if mainScreenNavBar.exists {
        print("✅ Already on main screen")
        return
    }
    
    // Try navigation methods in order of preference
    var navigationSuccess = false
    var attemptedMethods: [String] = []
    
    // Method 1: Back button (most reliable for standard navigation)
    let backButton = app.buttons["Back"]
    if backButton.exists && backButton.isHittable {
        print("🔙 Using Back button navigation")
        backButton.tap()
        navigationSuccess = mainScreenNavBar.waitForExistence(timeout: 3)
        attemptedMethods.append("Back button")
    }
    
    // Method 2: Navigation bar back button
    if !navigationSuccess {
        let navBackButton = app.navigationBars.buttons.firstMatch
        if navBackButton.exists && navBackButton.isHittable {
            print("🔙 Using navigation bar back button")
            navBackButton.tap()
            navigationSuccess = mainScreenNavBar.waitForExistence(timeout: 3)
            attemptedMethods.append("Navigation back button")
        }
    }
    
    // Method 3: Swipe gesture (fallback for modal presentations)
    if !navigationSuccess {
        print("🔙 Using swipe right gesture")
        app.swipeRight()
        navigationSuccess = mainScreenNavBar.waitForExistence(timeout: 3)
        attemptedMethods.append("Swipe right")
    }
    
    // Method 4: Dismiss action (for sheets/modals)
    if !navigationSuccess {
        let dismissButton = app.buttons["Dismiss"]
        if dismissButton.exists {
            print("🔙 Using Dismiss button")
            dismissButton.tap()
            navigationSuccess = mainScreenNavBar.waitForExistence(timeout: 3)
            attemptedMethods.append("Dismiss button")
        }
    }
    
    // FAIL HARD if navigation didn't work
    if !navigationSuccess {
        XCTFail("❌ CRITICAL: Failed to navigate back to main screen from \(location). " +
                "Attempted methods: \(attemptedMethods.joined(separator: ", ")). " +
                "Current view state: \(app.debugDescription)")
    } else {
        print("✅ Successfully navigated back to main screen using: \(attemptedMethods.last!)")
    }
}
```

### Validation Testing Pattern:
```swift
// ALWAYS validate expected state after operations
func addTagsToProperty() {
    // ... tag addition logic ...
    
    // VALIDATE the operation succeeded
    let addedTags = app.buttons.matching(identifier: "TagChip")
    let expectedTagCount = 3
    XCTAssertEqual(addedTags.count, expectedTagCount, 
                   "❌ Expected \(expectedTagCount) tags but found \(addedTags.count)")
    
    // VALIDATE navigation back to main screen
    navigateBackToMainScreen(in: app, from: "Property detail after adding tags")
}
```

---

## 🏗️ **Test Architecture Requirements**

### Component Testing:
- Every new UI component MUST have unit tests where applicable
- Every navigation flow MUST be tested end-to-end
- Every data display change MUST be validated with sample data

### Error Handling:
- UI tests MUST fail explicitly with clear error messages
- Never silently skip failed operations
- Always provide debugging context in failure messages

---

## 📊 **Test Validation Metrics**

### Required Test Validations:
- ✅ **Navigation flows work correctly**
- ✅ **UI elements respond as expected**
- ✅ **Data displays correctly**
- ✅ **Error states handle gracefully**
- ✅ **Performance within acceptable thresholds**

### Test Performance Thresholds:
- **UI test execution**: < 10 minutes for full suite
- **Navigation timeouts**: 3-5 seconds maximum
- **Screenshot generation**: < 5 minutes

---

## 📋 **Test Review Checklist**

Before approving any UI test changes, verify:

### ✅ **Navigation Robustness**
- [ ] Multiple navigation methods attempted
- [ ] Final screen state verified explicitly
- [ ] Clear failure messages with debugging info
- [ ] No silent failures allowed

### ✅ **State Verification**
- [ ] UI state verified before critical operations
- [ ] Assumptions about element existence checked
- [ ] Timeouts used appropriately
- [ ] Test fails explicitly when expectations aren't met

### ✅ **Error Handling**
- [ ] Comprehensive error messages
- [ ] Debugging information included
- [ ] No operations proceed after failures
- [ ] Test failures are actionable

### ✅ **Test Coverage**
- [ ] Critical user flows tested
- [ ] Edge cases considered
- [ ] Test covers actual user scenarios
- [ ] No false positives allowed

---

## 🚨 **Anti-Patterns to Avoid**

### ❌ **Silent Failures**
```swift
// DON'T DO THIS
_ = element.waitForExistence(timeout: 5)
// Test continues even if element never appeared
```

### ❌ **Weak Navigation**
```swift
// DON'T DO THIS
app.swipeRight()
// Assumes navigation worked without verification
```

### ❌ **Assumption-Based Testing**
```swift
// DON'T DO THIS
takeScreenshot("DetailView")
// Assumes we're actually on detail view
```

### ❌ **Generic Error Messages**
```swift
// DON'T DO THIS
XCTFail("Something went wrong")
// Provides no debugging information
```

---

## 🎯 **Testing Goals for Domori**

### **Screenshot Generation Tests**
1. **Fail hard** if navigation between screens fails
2. **Verify** we're on the correct screen before taking screenshots
3. **Provide** detailed debugging info for test failures
4. **Ensure** all critical user flows work as expected

### **Property Management Tests**
1. **Verify** property creation completes successfully
2. **Check** that tags are actually added and visible
3. **Confirm** navigation between property list and detail works
4. **Validate** form submissions and UI state changes

### **UI Element Tests**
1. **Test** that buttons are actually tappable
2. **Verify** text fields accept input correctly
3. **Check** that screens load within reasonable timeouts
4. **Ensure** all critical UI elements are accessible

---

## 📚 **Related Documentation**

- **Development Practices**: DEVELOPMENT_PRACTICES.md
- **UI Guidelines**: UI_GUIDELINES.md
- **Code Style**: CODE_STYLE.md
- **Screenshot Requirements**: SCREENSHOT_REQUIREMENTS.md
- **Commit Rules**: COMMIT_RULES.md 