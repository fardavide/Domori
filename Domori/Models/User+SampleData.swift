import Foundation

extension User {
    static let sampleData: [User] = [
        User(name: "Alice Johnson", email: "alice@example.com"),
        User(name: "Bob Smith", email: "bob@example.com"),
        User(name: "Carol Davis", email: "carol@example.com"),
        User(name: "David Wilson", email: "david@example.com")
    ]
}

extension SharedWorkspace {
    static func createSampleData(users: [User]) -> [SharedWorkspace] {
        guard users.count >= 2 else { return [] }
        
        let workspace1 = SharedWorkspace(name: "Downtown Properties", owner: users[0])
        workspace1.addMember(users[1])
        
        let workspace2 = SharedWorkspace(name: "Investment Portfolio", owner: users[1])
        workspace2.addMember(users[0])
        workspace2.addMember(users[2])
        
        return [workspace1, workspace2]
    }
}

extension WorkspaceInvitation {
    static func createSampleData(workspaces: [SharedWorkspace], users: [User]) -> [WorkspaceInvitation] {
        guard workspaces.count >= 1, users.count >= 3 else { return [] }
        
        let invitation1 = WorkspaceInvitation(
            inviteeEmail: "newuser@example.com",
            workspace: workspaces[0],
            inviter: users[0],
            message: "Join our property investment team! We're looking at some great opportunities downtown."
        )
        
        return [invitation1]
    }
} 