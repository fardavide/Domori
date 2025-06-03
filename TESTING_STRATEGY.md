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

## 🏷️ **TAG RATING SELECTION - PROVEN APPROACH**

### **✅ WORKING SOLUTION: Accessibility Identifiers with Multiple Fallbacks**

After extensive testing, this is the **ONLY reliable approach** for tag rating selection in UI tests:

```swift
// STEP 1: Map display name to PropertyRating raw value
let ratingRawValue: String
switch tag.rating {
case "Not Rated": ratingRawValue = "none"
case "Excluded": ratingRawValue = "excluded"  
case "Considering": ratingRawValue = "considering"
case "Good": ratingRawValue = "good"
case "Excellent": ratingRawValue = "excellent"
default: ratingRawValue = "good" // Safe fallback
}

// STEP 2: Primary method - Accessibility identifier (MOST RELIABLE)
let ratingButton = app.buttons["rating_\(ratingRawValue)"]
var ratingSelected = false

if ratingButton.waitForExistence(timeout: 2.0) && ratingButton.isHittable {
    ratingButton.tap()
    ratingSelected = true
    print("✅ Selected rating via accessibility identifier")
} else {
    // STEP 3: Fallback 1 - Text content search
    let ratingButtonByText = app.buttons.containing(NSPredicate(format: "label CONTAINS '\(tag.rating)'")).firstMatch
    if ratingButtonByText.exists && ratingButtonByText.isHittable {
        ratingButtonByText.tap()
        ratingSelected = true
        print("✅ Selected rating via text content fallback")
    } else {
        // STEP 4: Fallback 2 - Position-based selection
        let ratingIndex: Int
        switch tag.rating {
        case "Not Rated": ratingIndex = 0
        case "Excluded": ratingIndex = 1
        case "Considering": ratingIndex = 2
        case "Good": ratingIndex = 3
        case "Excellent": ratingIndex = 4
        default: ratingIndex = 3
        }
        
        let ratingButtons = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'rating_'"))
        if ratingButtons.count >= ratingIndex + 1 {
            let targetButton = ratingButtons.element(boundBy: ratingIndex)
            if targetButton.exists && targetButton.isHittable {
                targetButton.tap()
                ratingSelected = true
                print("✅ Selected rating via position fallback")
            }
        }
    }
}
```

### **🚨 CRITICAL REQUIREMENTS for Rating Selection:**

1. **AddTagView.swift MUST have accessibility identifiers**:
   ```swift
   .accessibilityIdentifier("rating_\(rating.rawValue)")
   ```

2. **UI tests MUST use the exact raw values**:
   - `"rating_none"`, `"rating_excluded"`, `"rating_considering"`, `"rating_good"`, `"rating_excellent"`

3. **Multiple fallback methods are ESSENTIAL**:
   - Primary: Accessibility identifier lookup
   - Fallback 1: Text content search  
   - Fallback 2: Position-based selection

4. **Comprehensive debugging MUST be included**:
   ```swift
   print("🔍 Available buttons: \(app.buttons.allElementsBoundByIndex.prefix(10).map { $0.identifier })")
   ```

### **⚡ PROVEN PERFORMANCE IMPROVEMENTS:**

The **efficient navigation pattern** that dramatically reduced test execution time:

```swift
private func addMultipleTagsToProperty(in app: XCUIApplication, propertyIndex: Int, tags: [(name: String, rating: String)]) {
    // Navigate to property ONCE
    navigateToProperty(propertyIndex)
    
    // Add ALL tags while staying in detail view
    for tag in tags {
        tapAddTagButton()
        fillTagName(tag.name)
        selectRatingWithFallbacks(tag.rating)  // Use proven method above
        createTag()
        // STAY in detail view - don't navigate back
    }
    
    // Navigate back to main screen ONLY ONCE after all tags added
    navigateBackToMainScreen(in: app, from: "addMultipleTagsToProperty")
}
```

**Performance Results:**
- **Before**: 4+ minutes (inefficient navigation)
- **After**: ~3.5 minutes (efficient navigation + working rating selection)

### **🎨 TAG COLOR VERIFICATION:**

With the working rating selection, tags now display correct colors:
- 🔵 **Blue** for Excellent ratings (`rating_excellent`)
- 🟢 **Green** for Good ratings (`rating_good`)  
- 🟠 **Orange** for Considering ratings (`rating_considering`)
- 🔴 **Red** for Excluded ratings (`rating_excluded`)
- ⚪ **Gray** for Not Rated (`rating_none`)

---

## 📚 **Related Documentation**

- **Development Practices**: DEVELOPMENT_PRACTICES.md
- **UI Guidelines**: UI_GUIDELINES.md
- **Code Style**: CODE_STYLE.md
- **Screenshot Requirements**: SCREENSHOT_REQUIREMENTS.md
- **Commit Rules**: COMMIT_RULES.md

## 📸 Screenshot Testing (Critical for UI Validation)

### **Platform-Specific Screenshot Tests (Use These Only)**

**⚠️ IMPORTANT: Always use platform-specific test functions, never the generic ones**

#### iPhone Screenshots:
```bash
xcodebuild test -scheme Domori -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' \
  -only-testing:DomoriUITests/DomoriUITests/testAppStoreScreenshots_iPhone
```

#### iPad Screenshots:
```bash
xcodebuild test -scheme Domori -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4),OS=18.5' \
  -only-testing:DomoriUITests/DomoriUITests/testAppStoreScreenshots_iPad
```

#### Mac Screenshots:
```bash
xcodebuild test -scheme Domori -destination 'platform=macOS,arch=arm64' \
  -only-testing:DomoriUITests/DomoriUITests/testAppStoreScreenshots_Mac
```

### **Why Platform-Specific Tests Are Required:**

1. **Correct Device Context**: Each test runs on the appropriate device/simulator
2. **Proper Screen Dimensions**: Screenshots are captured at correct resolutions
3. **Platform-Specific UI**: Different platforms may show different UI elements
4. **No Duplicate Screenshots**: Avoids generating the same screenshots multiple times
5. **Proper File Naming**: Screenshots are named correctly for each platform

### **Screenshot Test Results:**

Screenshots are saved in the `AppStoreScreenshots/` directory with platform prefixes:
- `01_iPhone_MainScreen_ThreeListings.png`
- `02_iPhone_AddProperty_FilledForm.png` 
- `03_iPhone_PropertyDetail.png`
- `04_iPhone_TagAddition.png`
- (Similar for iPad and Mac with their respective prefixes)

### **Test Execution Rules:**

❌ **NEVER use generic test functions** - they cause duplicate runs and wrong naming
✅ **Always use platform-specific functions** for screenshot generation
❌ **NEVER commit when ANY test fails** - investigate and fix failures first
✅ **Always verify screenshots were actually updated** by checking file timestamps 