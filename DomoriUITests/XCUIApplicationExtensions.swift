import XCUIAutomation

extension XCUIApplication {
  
  var mainRobot: PropertiesListRobot {
    PropertiesListRobot(app: self)
  }
}
