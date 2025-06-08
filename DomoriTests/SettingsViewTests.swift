import XCTest
import SwiftUI
@testable import Domori

class SettingsViewTests: XCTestCase {

    func testWorkspaceRowViewInitialization() {
        // Create a mock workspace
        let mockUser = User(name: "Test User", email: "test@example.com")
        let mockWorkspace = SharedWorkspace(name: "Test Workspace", owner: mockUser)
        
        // Test workspace row view creation
        let workspaceRow = WorkspaceRowView(workspace: mockWorkspace, showOwner: true) {
            // Mock tap action
        }
        
        XCTAssertNotNil(workspaceRow)
    }
    
    func testWorkspaceOwnershipLogic() {
        // Create test users
        let owner = User(name: "Owner", email: "owner@example.com")
        let member = User(name: "Member", email: "member@example.com")
        
        // Create workspace
        let workspace = SharedWorkspace(name: "Test Workspace", owner: owner)
        
        // Test ownership checks
        XCTAssertTrue(workspace.isUserOwner(owner))
        XCTAssertFalse(workspace.isUserOwner(member))
    }
    
    func testUserPrimaryWorkspace() {
        // Create test user
        let user = User(name: "Test User", email: "test@example.com")
        
        // Initially no primary workspace
        XCTAssertNil(user.primaryWorkspace)
        
        // Create personal workspace
        let personalWorkspace = SharedWorkspace(name: "Personal Workspace", owner: user)
        user.ownedWorkspace = personalWorkspace
        
        // Should have primary workspace now
        XCTAssertNotNil(user.primaryWorkspace)
        XCTAssertEqual(user.primaryWorkspace?.name, "Personal Workspace")
    }
} 