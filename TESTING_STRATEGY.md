# Testing Strategy - Domori

## 🚨 CRITICAL SCREENSHOT REQUIREMENTS

### MANDATORY FIELDS (NEVER EMPTY!)
These fields MUST be filled in every screenshot test:

- **💰 PRICE**: €485,000, €750,000, etc. (Position 0 in numeric fields)
- **📐 SIZE**: 85, 120, 150 sqm (Position 1 in numeric fields)  
- **🛏️ BEDROOMS**: 2, 3, 4 (Stepper control with "Bedrooms" label)
- **🚿 BATHROOMS**: 1, 2, 3 (Picker control with "Bathrooms" label)
- **⭐ RATING**: Good, Excellent, etc. (Rating buttons or picker)
- **🏷️ TAGS**: 2-3 per property with different colors and ratings

**Tests MUST FAIL if any of these are empty in screenshots!**

## 📸 Screenshot Test Configuration

### Test Methods
```swift
testAppStoreScreenshots_iPhone() // iPhone 16 Pro
testAppStoreScreenshots_iPad()   // iPad Pro 13-inch (M4)
testAppStoreScreenshots_Mac()    // Mac
```

### Screenshot Flow (EXACT SEQUENCE)
1. **Create Property 1** → Fill form → **Take Screen 02** → Save → Add tags → Go to main
2. **Create Property 2** → Fill form → **Take Screen 02** (overwrite) → Save → Add tags → Go to main  
3. **Create Property 3** → Fill form → **Take Screen 02** (overwrite) → Save → Add tags → Go to main
4. **Take Screen 01**: Main screen with 3 properties
5. **Take Screen 03**: Open first property detail
6. **Take Screen 04**: Open tag addition screen
7. **Take Screen 05**: Open property comparison

### Screenshot Naming Convention
```
{ScreenNumber}_{Platform}_{ScreenName}.png

Examples:
01_iPhone_MainScreen_ThreeListings.png
02_iPhone_AddProperty_FilledForm.png
03_iPhone_PropertyDetail.png
04_iPhone_TagAddition.png
05_iPhone_PropertyComparison.png
```

## 🔧 Technical Implementation Details

### Field Filling Logic

#### Text Fields (Price, Size)
```swift
// Find TextFields with placeholder "0"
let numericFields = app.textFields.matching(NSPredicate(format: "placeholderValue == '0'"))
// Position 0 = Price, Position 1 = Size
```

#### Bedrooms (Stepper)
```swift
// Find stepper with "Bedrooms" in label
let bedroomsSteppers = app.steppers.matching(NSPredicate(format: "label CONTAINS 'Bedrooms'"))
```

#### Bathrooms (Picker)
```swift
// Find "Bathrooms" label, then nearby picker
let bathroomsLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Bathrooms'"))
```

### Text Input Fix
**CRITICAL**: Use proper text selection to avoid "1200" when typing "120" in field with "0":
```swift
extension XCUIElement {
    func clearAndTypeText(_ text: String) {
        self.tap()                    // Focus field
        Thread.sleep(forTimeInterval: 0.1)
        self.doubleTap()             // Select all text
        Thread.sleep(forTimeInterval: 0.1)  
        self.typeText(text)          // Replace selected text
    }
}
```

### Sample Property Data
```swift
let sampleProperties = [
    (title: "Modern City Apartment", 
     location: "Via Roma 123, Milano, Italy", 
     price: "485000", size: "85", bedrooms: "2",
     tags: [("Prime Location", "Excellent"), ("Investment Grade", "Good"), ("High Price Point", "Considering")]),
    (title: "Victorian Townhouse", 
     location: "Kurfürstendamm 45, Berlin, Germany", 
     price: "750000", size: "120", bedrooms: "3",
     tags: [("Historic Charm", "Good"), ("Renovation Needed", "Considering"), ("Good Value", "Good")]),
    (title: "Riverside Penthouse", 
     location: "Quai des Grands Augustins 12, Paris, France", 
     price: "1250000", size: "150", bedrooms: "4",
     tags: [("Luxury Features", "Good"), ("Very Expensive", "Excluded"), ("Great Views", "Good")])
]
```

## 🚀 Running Screenshot Tests

### Individual Platform Tests
```bash
# iPhone (Primary - Use for verification)
xcodebuild test -project Domori.xcodeproj -scheme Domori \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:DomoriUITests/DomoriUITests/testAppStoreScreenshots_iPhone

# iPad
xcodebuild test -project Domori.xcodeproj -scheme Domori \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' \
  -only-testing:DomoriUITests/DomoriUITests/testAppStoreScreenshots_iPad

# Mac
xcodebuild test -project Domori.xcodeproj -scheme Domori \
  -destination 'platform=macOS,arch=arm64' \
  -only-testing:DomoriUITests/DomoriUITests/testAppStoreScreenshots_Mac
```

### All Platforms (Full Suite)
```bash
xcodebuild test -project Domori.xcodeproj -scheme Domori \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' \
  -destination 'platform=macOS,arch=arm64' \
  -only-testing:DomoriUITests/DomoriUITests/testAppStoreScreenshots_iPhone \
  -only-testing:DomoriUITests/DomoriUITests/testAppStoreScreenshots_iPad \
  -only-testing:DomoriUITests/DomoriUITests/testAppStoreScreenshots_Mac
```

## 🔍 Verification Checklist

### Screenshot Quality Check
- [ ] **02_Platform_AddProperty_FilledForm.png**: ALL mandatory fields visible and filled
- [ ] **01_Platform_MainScreen_ThreeListings.png**: 3 properties with tags visible
- [ ] **03_Platform_PropertyDetail.png**: Property details with tags visible
- [ ] **04_Platform_TagAddition.png**: Add tag screen with form filled
- [ ] **05_Platform_PropertyComparison.png**: Compare screen with 2+ properties

### File Verification
```bash
# Check all screenshots generated
ls -la AppStoreScreenshots/
# Should show 15 files total (5 × 3 platforms)

# Check timestamp to verify latest run
ls -la AppStoreScreenshots/02_iPhone_AddProperty_FilledForm.png
```

## 🐛 Troubleshooting

### Common Issues

#### Empty Fields in Screenshots
- **Cause**: Text selection not working properly
- **Fix**: Check `clearAndTypeText` extension implementation
- **Verify**: Double-tap selects all text before typing

#### Steppers/Pickers Not Working
- **Cause**: Element not found or not hittable
- **Fix**: Check element identification logic in `fillBedroomsWithStepper` and `fillBathroomsWithPicker`
- **Debug**: Add element debug logging

#### Navigation Failures
- **Cause**: Unexpected screen state
- **Fix**: Check `ensureOnMainScreen` and `navigateBackToMainScreen` logic
- **Verify**: Navigation bar titles match expected values

#### Screenshot Timing
- **Cause**: UI not settled before screenshot
- **Fix**: Use `waitForUIToSettle` before taking screenshots
- **Timing**: Standard test run ~160 seconds for iPhone

### Debug Commands
```bash
# View test results with details
xcrun xcresulttool get --path [xcresult_path] --format json

# Check simulator state
xcrun simctl list devices | grep "iPhone 16 Pro"
``` 