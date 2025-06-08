import Testing
import SwiftData
@testable import Domori

struct WorkspaceOwnershipTests {
    
    @Test func testWorkspaceOwnershipDetection() async throws {
        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, SharedWorkspace.self, configurations: config)
        let context = await container.mainContext
        
        // Create a user and workspace
        let owner = User(name: "Test Owner", email: "owner@test.com")
        let member = User(name: "Test Member", email: "member@test.com")
        
        context.insert(owner)
        context.insert(member)
        
        let workspace = SharedWorkspace(name: "Test Workspace", owner: owner)
        context.insert(workspace)
        
        // Add member to workspace
        workspace.addMember(member)
        
        try context.save()
        
        // Test ownership detection
        #expect(workspace.isUserOwner(owner) == true)
        #expect(workspace.isUserOwner(member) == false)
        
        // Test that owner and member have different IDs (this was the root of the bug)
        #expect(owner.id != member.id)
        
        // Test that workspace.owner has the same ID as the owner user
        #expect(workspace.owner?.id == owner.id)
    }
    
    @Test func testWorkspaceOwnershipWithSameEmailDifferentId() async throws {
        // This test verifies the specific bug we fixed
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, SharedWorkspace.self, configurations: config)
        let context = await container.mainContext
        
        // Create a user and workspace
        let owner = User(name: "Test User", email: "test@example.com")
        context.insert(owner)
        
        let workspace = SharedWorkspace(name: "Test Workspace", owner: owner)
        context.insert(workspace)
        
        try context.save()
        
        // Create a new User object with same name/email but different ID (simulating the old bug)
        let tempUser = User(name: owner.name, email: owner.email)
        
        // The temp user should NOT be detected as owner because it has a different ID
        #expect(workspace.isUserOwner(tempUser) == false)
        
        // But the actual owner should be detected correctly
        #expect(workspace.isUserOwner(owner) == true)
        
        // Verify they have different IDs
        #expect(owner.id != tempUser.id)
        
        // But same email
        #expect(owner.email == tempUser.email)
    }
} 