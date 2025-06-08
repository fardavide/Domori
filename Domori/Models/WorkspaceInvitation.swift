import Foundation
import SwiftData

@Model
final class WorkspaceInvitation {
    var id: String = UUID().uuidString
    var inviteeEmail: String = ""
    var message: String = ""
    var status: InvitationStatus = InvitationStatus.pending
    var createdDate: Date = Date()
    var respondedDate: Date?
    var expiryDate: Date = Date().addingTimeInterval(7 * 24 * 60 * 60) // 7 days
    
    // Relationships
    var workspace: SharedWorkspace?
    @Relationship(inverse: \User.sentInvitations) var inviter: User?
    @Relationship(inverse: \User.receivedInvitations) var invitee: User?
    
    init(inviteeEmail: String, workspace: SharedWorkspace, inviter: User, message: String = "") {
        self.inviteeEmail = inviteeEmail
        self.workspace = workspace
        self.inviter = inviter
        self.message = message
        self.createdDate = Date()
    }
    
    func accept() {
        status = .accepted
        respondedDate = Date()
    }
    
    func decline() {
        status = .declined
        respondedDate = Date()
    }
    
    func cancel() {
        status = .cancelled
        respondedDate = Date()
    }
    
    var isExpired: Bool {
        return Date() > expiryDate
    }
    
    var isActive: Bool {
        return status == .pending && !isExpired
    }
}

enum InvitationStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case accepted = "Accepted"
    case declined = "Declined"
    case cancelled = "Cancelled"
    
    var displayName: String {
        return rawValue
    }
    
    var systemImage: String {
        switch self {
        case .pending: return "clock"
        case .accepted: return "checkmark.circle.fill"
        case .declined: return "xmark.circle.fill"
        case .cancelled: return "minus.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .accepted: return "green"
        case .declined: return "red"
        case .cancelled: return "gray"
        }
    }
} 