# Robot Pattern Implementation for Domori UI Tests

This implementation follows the correct Robot Pattern architecture as requested, with proper separation of concerns.

## 📁 Folder Structure

```
DomoriUITests/
├── PropertiesList/
│   ├── PropertiesListSemantics.swift    # UI element coordinates only
│   ├── PropertiesListRobot.swift        # Actions + verify{} method
│   └── PropertiesListVerifier.swift     # Assertions only
├── AddProperty/
│   ├── AddPropertySemantics.swift       # UI element coordinates only
│   ├── AddPropertyRobot.swift           # Actions + verify{} method
│   └── AddPropertyVerifier.swift        # Assertions only
├── PropertyDetails/
│   ├── PropertyDetailsSemantics.swift   # UI element coordinates only
│   ├── PropertyDetailsRobot.swift       # Actions + verify{} method
│   └── PropertyDetailsVerifier.swift    # Assertions only
└── AddEditPropertiesTest.swift          # Main test using Robot pattern
```

## 🏗️ Pattern Architecture

### 1. **Semantics** (UI Element Coordinates)
- Contains **ONLY** UI element locators/coordinates
- No actions, no assertions
- Examples: `editButton`, `titleField`, `saveButton`
- Pure element references like `app.buttons["Edit"]`

```swift
struct PropertiesListSemantics {
    var addButton: XCUIElement {
        navigationBar.buttons["plus"]
    }
    
    var firstPropertyCell: XCUIElement {
        propertiesCollection.cells.element(boundBy: 0)
    }
}
```

### 2. **Robot** (Actions + Verify Method)
- Uses Semantics for element location
- Contains all user actions (tap, fill, navigate)
- Provides `verify{}` method that accepts Verifier lambda
- Returns other Robots for navigation flow

```swift
class PropertiesListRobot {
    private let semantics: PropertiesListSemantics
    
    func tapAddProperty() -> AddPropertyRobot {
        semantics.addButton.tap()
        return AddPropertyRobot(app: semantics.app)
    }
    
    func verify(_ verifierAction: (PropertiesListVerifier) -> Void) {
        let verifier = PropertiesListVerifier(semantics: semantics)
        verifierAction(verifier)
    }
}
```

### 3. **Verifier** (Assertions Only)
- Uses Semantics for element references
- Contains **ONLY** assertions/verifications
- No actions, just XCTAssert statements
- Chainable methods for multiple assertions

```swift
class PropertiesListVerifier {
    private let semantics: PropertiesListSemantics
    
    func verifyPropertyExists(title: String) -> PropertiesListVerifier {
        XCTAssertTrue(semantics.propertyWithTitle(title).exists)
        return self
    }
}
```

## 🔄 Usage Flow

### Correct Pattern Usage:
```swift
// Robot performs actions and uses verify{} for assertions
propertiesListRobot
    .waitForScreen()
    .verify { verifier in
        verifier.verifyNavigationExists()
               .verifyAddButtonExists()
    }
    .tapAddProperty()
    .waitForScreen()
    .fillTitle("Test Property")
    .verify { verifier in
        verifier.verifySaveButtonEnabled()
    }
    .save()
```

### Key Benefits:
1. **Separation of Concerns**: UI coordinates, actions, and assertions are completely separated
2. **Maintainability**: UI changes only require updating Semantics
3. **Readability**: Clear distinction between what elements are vs. what actions do
4. **Reusability**: Semantics and Verifiers can be reused across multiple tests
5. **Chainable**: Fluent interface with clear action flows

## 📝 Test Implementation

The `AddEditPropertiesTest` demonstrates the complete pattern:
- Uses only Robot classes for test orchestration
- Leverages `verify{}` method for all assertions
- Follows clear action → verify → action flow
- Comprehensive coverage of all property operations

## ⚠️ Important Notes

- **Semantics**: Never contains actions or assertions, only element references
- **Robot**: Never calls `app.buttons["Edit"]` directly, only uses `semantics.editButton`
- **Verifier**: Never performs actions, only assertions
- **Test**: Only uses Robot classes, never Semantics or Verifier directly 