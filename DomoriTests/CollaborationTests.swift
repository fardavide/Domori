import Testing
import SwiftData
@testable import Domori

struct CollaborationTests {
    
    @Test func testUserCreation() async throws {
        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, configurations: config)
        let context = await container.mainContext
        
        // Create a user
        let user = User(name: "Test User", email: "test@example.com")
        context.insert(user)
        
        // Verify user properties
        #expect(user.name == "Test User")
        #expect(user.email == "test@example.com")
        #expect(user.id.isEmpty == false)
        #expect(user.ownedWorkspaces?.isEmpty == true)
        #expect(user.getMemberWorkspaces().isEmpty == true)
    }
    
    @Test func testSharedWorkspaceCreation() async throws {
        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, SharedWorkspace.self, configurations: config)
        let context = await container.mainContext
        
        // Create a user and workspace
        let owner = User(name: "Owner", email: "owner@example.com")
        context.insert(owner)
        
        let workspace = SharedWorkspace(name: "Test Workspace", owner: owner)
        context.insert(workspace)
        
        // Verify workspace properties
        #expect(workspace.name == "Test Workspace")
        #expect(workspace.owner?.email == "owner@example.com")
        #expect(workspace.ownerEmail == "owner@example.com")
        #expect(workspace.isActive == true)
        #expect(workspace.members?.isEmpty == true)
        #expect(workspace.properties?.isEmpty == true)
    }
    
    @Test func testWorkspaceMemberManagement() async throws {
        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, SharedWorkspace.self, configurations: config)
        let context = await container.mainContext
        
        // Create users and workspace
        let owner = User(name: "Owner", email: "owner@example.com")
        let member1 = User(name: "Member 1", email: "member1@example.com")
        let member2 = User(name: "Member 2", email: "member2@example.com")
        
        context.insert(owner)
        context.insert(member1)
        context.insert(member2)
        
        let workspace = SharedWorkspace(name: "Test Workspace", owner: owner)
        context.insert(workspace)
        
        // Add members
        workspace.addMember(member1)
        workspace.addMember(member2)
        
        // Verify members were added
        #expect(workspace.members?.count == 2)
        #expect(workspace.isUserMember(member1) == true)
        #expect(workspace.isUserMember(member2) == true)
        #expect(workspace.isUserOwner(owner) == true)
        #expect(workspace.isUserOwner(member1) == false)
        
        // Test all participants
        let allParticipants = workspace.allParticipants
        #expect(allParticipants.count == 3) // owner + 2 members
        
        // Remove a member
        workspace.removeMember(member1)
        #expect(workspace.members?.count == 1)
        #expect(workspace.isUserMember(member1) == false)
        #expect(workspace.isUserMember(member2) == true)
    }
    
    @Test func testWorkspaceInvitation() async throws {
        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, SharedWorkspace.self, WorkspaceInvitation.self, configurations: config)
        let context = await container.mainContext
        
        // Create user and workspace
        let inviter = User(name: "Inviter", email: "inviter@example.com")
        context.insert(inviter)
        
        let workspace = SharedWorkspace(name: "Test Workspace", owner: inviter)
        context.insert(workspace)
        
        // Create invitation
        let invitation = WorkspaceInvitation(
            inviteeEmail: "invitee@example.com",
            workspace: workspace,
            inviter: inviter,
            message: "Join our workspace!"
        )
        context.insert(invitation)
        
        // Verify invitation properties
        #expect(invitation.inviteeEmail == "invitee@example.com")
        #expect(invitation.message == "Join our workspace!")
        #expect(invitation.status == .pending)
        #expect(invitation.isActive == true)
        #expect(invitation.isExpired == false)
        #expect(invitation.workspace?.name == "Test Workspace")
        #expect(invitation.inviter?.email == "inviter@example.com")
    }
    
    @Test func testInvitationStatusChanges() async throws {
        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, SharedWorkspace.self, WorkspaceInvitation.self, configurations: config)
        let context = await container.mainContext
        
        // Create user and workspace
        let inviter = User(name: "Inviter", email: "inviter@example.com")
        context.insert(inviter)
        
        let workspace = SharedWorkspace(name: "Test Workspace", owner: inviter)
        context.insert(workspace)
        
        // Create invitation
        let invitation = WorkspaceInvitation(
            inviteeEmail: "invitee@example.com",
            workspace: workspace,
            inviter: inviter
        )
        context.insert(invitation)
        
        // Test accepting invitation
        invitation.accept()
        #expect(invitation.status == .accepted)
        #expect(invitation.respondedDate != nil)
        #expect(invitation.isActive == false)
        
        // Create another invitation to test declining
        let invitation2 = WorkspaceInvitation(
            inviteeEmail: "invitee2@example.com",
            workspace: workspace,
            inviter: inviter
        )
        context.insert(invitation2)
        
        invitation2.decline()
        #expect(invitation2.status == .declined)
        #expect(invitation2.respondedDate != nil)
        #expect(invitation2.isActive == false)
        
        // Create another invitation to test cancelling
        let invitation3 = WorkspaceInvitation(
            inviteeEmail: "invitee3@example.com",
            workspace: workspace,
            inviter: inviter
        )
        context.insert(invitation3)
        
        invitation3.cancel()
        #expect(invitation3.status == .cancelled)
        #expect(invitation3.respondedDate != nil)
        #expect(invitation3.isActive == false)
    }
    
    @Test func testPropertySharing() async throws {
        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PropertyListing.self, User.self, SharedWorkspace.self, configurations: config)
        let context = await container.mainContext
        
        // Create user and workspace
        let owner = User(name: "Owner", email: "owner@example.com")
        context.insert(owner)
        
        let workspace = SharedWorkspace(name: "Test Workspace", owner: owner)
        context.insert(workspace)
        
        // Create property
        let property = PropertyListing(
            title: "Test Property",
            location: "Test Location",
            price: 100000,
            size: 100,
            bedrooms: 2,
            bathrooms: 1,
            propertyType: .apartment
        )
        context.insert(property)
        
        // Share property with workspace
        property.sharedWorkspace = workspace
        
        // Verify sharing
        #expect(property.sharedWorkspace?.name == "Test Workspace")
        #expect(workspace.properties?.contains(property) == true)
    }
    
    @Test func testUserManager() async throws {
        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, configurations: config)
        let context = await container.mainContext
        
        let userManager = UserManager.shared
        
        // Initially should require sign in
        #expect(userManager.requiresSignIn == true)
        #expect(userManager.currentUser == nil)
        
        // Sign in user
        userManager.signIn(name: "Test User", email: "test@example.com", context: context)
        
        // Should be signed in now
        #expect(userManager.requiresSignIn == false)
        #expect(userManager.currentUser?.name == "Test User")
        #expect(userManager.currentUser?.email == "test@example.com")
        
        // Sign out
        userManager.signOut()
        
        // Should require sign in again
        #expect(userManager.requiresSignIn == true)
        #expect(userManager.currentUser == nil)
    }
} 