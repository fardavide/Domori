import XCTest

/**
 # AddEditPropertiesTest - Robot Pattern Implementation
 
 This test follows the Robot Pattern for UI test architecture:
 
 ## Pattern Structure:
 - **Semantics**: UI element coordinates/locators only (PropertiesListSemantics, AddPropertySemantics, PropertyDetailsSemantics)
 - **Robot**: Actions using Semantics + verify {} method (PropertiesListRobot, AddPropertyRobot, PropertyDetailsRobot)
 - **Verifier**: Assertions only (PropertiesListVerifier, AddPropertyVerifier, PropertyDetailsVerifier)
 
 ## Test Flow:
 1. Add first property with all fields
 2. Verify property in list view
 3. Verify property in detail view
 4. Update property fields
 5. Verify updates in detail view
 6. Verify updates in list view
 7. Add second property with all fields
 8. Verify second property in list view
 9. Verify second property in detail view
 10. Update second property fields
 11. Verify updates in detail view
 12. Final verification in list view
 
 The test ensures comprehensive coverage of property creation, editing, and display across all app views.
 */

final class AddEditPropertiesTest: XCTestCase {
  
  var app: XCUIApplication!
  
  override func setUpWithError() throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments += ["uitest"]
    app.launch()
  }
  
  func testAddEditPropertiesWorkflow() throws {
    // STEP 1: Add first property with all fields
    _ = app.mainRobot
      .waitForScreen()
      .verify { verifier in
        verifier
          .verifyNavigationExists()
          .verifyAddButtonExists()
      }
      .tapAdd()
      .waitForScreen()
      .verify { verifier in
        verifier.verifyNavigationExists()
          .verifyTitleFieldExists()
          .verifyLocationFieldExists()
          .verifyNumericFieldsExist()
      }
      .fillTitle("Modern City Apartment")
      .fillLocation("Via Roma 123, Milano, Italy")
      .fillLink("https://property1.example.com")
      .fillAgentContact("John Doe: +39 123 456 7890")
      .fillPrice("485000")
      .fillSize("85")
      .setBedrooms(2)
      .setBathrooms(1.5)
      .setPropertyType("Apartment")
      .setPropertyRating("Excellent")
      .verify { verifier in
        verifier
          .verifySaveButtonExists()
          .verifySaveButtonEnabled()
      }
      .save()
    // STEP 2: Verify first property
      .verify { verifier in
        verifier
          .verifyNavigationExists()
          .verifyPropertyExists(title: "Modern City Apartment")
          .verifyPropertyExists(price: "485")
          .verifyPropertiesCount(1)
      }
      .tapFirstProperty()
      .waitForScreen()
      .verify { verifier in
        verifier
          .verifyDetailViewExists()
          .verifyTitle("Modern City Apartment")
          .verifyLocation("Milano")
          .verifyPrice("485")
          .verifySize("85")
          .verifyBedrooms(2)
          .verifyBathrooms(1.5)
          .verifyTagsSection()
          .verifyAddTagButtonExists()
      }
    // STEP 3: Edit first property
      .addTag(name: "Prime Location", rating: "Excellent")
      .verify { verifier in
        verifier.verifyTagExists("Prime Location")
      }
      .verify { $0.verifyEditButtonExists() }
      .tapEdit()
      .waitForScreen()
      .fillTitle("Modern City Apartment - Updated")
      .fillPrice("495000")
      .setBedrooms(3)
      .verify { $0.verifyUpdateButtonEnabled()
      }
      .update()
      .navigateBack()
    // STEP 4: Verify first property edits
      .tapFirstProperty()
      .waitForScreen()
      .verify { verifier in
        verifier
          .verifyTitle("Modern City Apartment - Updated")
          .verifyLocation("Milano")
          .verifyPrice("495")
          .verifySize("85")
          .verifyBedrooms(3)
          .verifyBathrooms(1.5)
          .verifyTagExists("Prime Location")
      }
      .navigateBack()
      .verify { verifier in
        verifier
          .verifyPropertyExists(title: "Modern City Apartment - Updated")
          .verifyPropertyExists(price: "495")
          .verifyPropertiesCount(1)
      }
    // STEP 5: Add second property
      .tapAdd()
      .waitForScreen()
      .fillTitle("Victorian Townhouse")
      .fillLocation("Kurfürstendamm 45, Berlin, Germany")
      .fillLink("https://property2.example.com")
      .fillAgentContact("Jane Smith: +49 30 123 4567")
      .fillPrice("750000")
      .fillSize("120")
      .setBedrooms(3)
      .setBathrooms(2.0)
      .setPropertyType("Townhouse")
      .setPropertyRating("Good")
      .save()
    // STEP 6: Verify second property
      .verify { verifier in
        verifier
          .verifyPropertiesCount(2)
          .verifyPropertyExists(title: "Victorian Townhouse")
          .verifyPropertyExists(price: "750")
      }
      .tapFirstProperty() // Newly added property
      .waitForScreen()
      .verify { verifier in
        verifier
          .verifyTitle("Victorian Townhouse")
          .verifyLocation("Berlin")
          .verifyPrice("750")
          .verifySize("120")
          .verifyBedrooms(3)
          .verifyBathrooms(2.0)
          .verifyTagsSection()
      }
    // STEP 7: Edit sefond property
      .addTag(name: "Historic Charm", rating: "Good")
      .verify { $0.verifyTagExists("Historic Charm") }
      .addTag(name: "Renovation Needed", rating: "Considering")
      .verify { $0.verifyTagExists("Renovation Needed") }
      .tapEdit()
      .waitForScreen()
      .fillLocation("Kurfürstendamm 45, Berlin, Germany - Prime District")
      .fillSize("125")
      .setBathrooms(2.5)
      .update()
      .navigateBack()
      .tapFirstProperty()
      .waitForScreen()
    // STEP 8: Verify second property edits
      .verify { verifier in
        verifier
          .verifyTitle("Victorian Townhouse")
          .verifyLocation("Kurfürstendamm 45, Berlin, Germany - Prime District")
          .verifyPrice("750")
          .verifySize("125")
          .verifyBedrooms(3)
          .verifyBathrooms(2.5)
          .verifyTagExists("Historic Charm")
          .verifyTagExists("Renovation Needed")
      }
      .navigateBack()
      .verify { verifier in
        verifier
          .verifyPropertiesCount(2)
          .verifyPropertyExists(title: "Modern City Apartment - Updated")
          .verifyPropertyExists(title: "Victorian Townhouse")
          .verifyPropertyExists(price: "495")
          .verifyPropertyExists(price: "750")
      }
  }
  
  func testEditPropertyWithSameName() throws {
    _ = app.mainRobot
      .tapAdd()
      .fillTitle("Property")
      .fillLocation("Location one")
      .fillLink("https://property.com/one")
      .save()
      .verify { $0.verifyPropertiesCount(1) }
      .tapAdd()
      .fillTitle("Property")
      .fillLocation("Location two")
      .fillLink("https://property.com/two")
      .save()
      .verify { verifier in
        verifier
          .verifyPropertiesCount(2)
          .verifyPropertyExists(location: "Location one")
          .verifyPropertyExists(location: "Location two")
      }
  }
}
