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
// ❌ WEAK - Silent failure
if app.buttons["Back"].exists {
    app.buttons["Back"].tap()
}

// ✅ STRONG - Explicit verification
func navigateBackToMainScreen(from location: String) {
    // Try multiple methods
    var success = false
    
    // Method 1: Back button
    if backButton.exists && backButton.isHittable {
        backButton.tap()
        success = mainScreen.waitForExistence(timeout: 5)
    }
    
    // Method 2: Alternative approaches...
    
    // FAIL HARD if nothing worked
    if !success {
        XCTFail("Critical navigation failure from \(location)")
    }
}
```

### State Verification Pattern:
```swift
// ❌ WEAK - No verification
takeScreenshot("MainScreen")

// ✅ STRONG - Verify state first
guard app.navigationBars["Properties"].exists else {
    XCTFail("Not on main screen - cannot take MainScreen screenshot")
}
takeScreenshot("MainScreen")
```

### Error Reporting Pattern:
```swift
// ❌ WEAK - Minimal info
print("Navigation failed")

// ✅ STRONG - Comprehensive debugging
let errorMessage = """
❌ CRITICAL NAVIGATION FAILURE ❌
From: \(location)
Attempted: \(methods)
Current state: \(debugInfo)
Available elements: \(elements)
"""
print(errorMessage)
XCTFail(errorMessage)
```

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

- **Code Style**: CODE_STYLE.md
- **Screenshot Requirements**: SCREENSHOT_REQUIREMENTS.md
- **Commit Rules**: COMMIT_RULES.md 