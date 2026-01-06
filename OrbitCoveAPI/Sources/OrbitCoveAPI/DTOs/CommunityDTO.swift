import Fluent
import Vapor

// MARK: - Request DTOs

/// Create community request
struct CreateCommunityRequest: Content {
    let name: String
    var description: String?
    var iconUrl: String?
}

/// Update community request
struct UpdateCommunityRequest: Content {
    var name: String?
    var description: String?
    var iconUrl: String?
    var settings: CommunitySettings?
}

/// Join community request
struct JoinCommunityRequest: Content {
    let code: String
}

/// Create invite request
struct CreateInviteRequest: Content {
    var usesRemaining: Int?
    var expiresInHours: Int?
}

/// Update member role request
struct UpdateMemberRequest: Content {
    var role: String?
    var nickname: String?
}

// MARK: - Response DTOs

/// Community response (safe for API output)
struct CommunityResponse: Content {
    let id: UUID
    let name: String
    let description: String?
    let iconUrl: String?
    let memberCount: Int
    let createdAt: Date?
    let createdBy: UUID

    init(from community: Community) {
        self.id = community.id!
        self.name = community.name
        self.description = community.description
        self.iconUrl = community.iconUrl
        self.memberCount = community.memberCount
        self.createdAt = community.createdAt
        self.createdBy = community.$createdBy.id
    }
}

/// Community with full details (for admins)
struct CommunityDetailResponse: Content {
    let id: UUID
    let name: String
    let description: String?
    let iconUrl: String?
    let memberCount: Int
    let subscriptionStatus: String
    let settings: CommunitySettings
    let createdAt: Date?
    let createdBy: UUID

    init(from community: Community) {
        self.id = community.id!
        self.name = community.name
        self.description = community.description
        self.iconUrl = community.iconUrl
        self.memberCount = community.memberCount
        self.subscriptionStatus = community.subscriptionStatus.rawValue
        self.settings = community.settings
        self.createdAt = community.createdAt
        self.createdBy = community.$createdBy.id
    }
}

/// Member response
struct MemberResponse: Content {
    let id: UUID
    let userId: UUID
    let displayName: String
    let avatarUrl: String?
    let role: String
    let nickname: String?
    let joinedAt: Date?

    init(from member: Member, user: User) {
        self.id = member.id!
        self.userId = user.id!
        self.displayName = user.displayName
        self.avatarUrl = user.avatarUrl
        self.role = member.role.rawValue
        self.nickname = member.nickname
        self.joinedAt = member.joinedAt
    }
}

/// Invite response
struct InviteResponse: Content {
    let id: UUID
    let code: String
    let usesRemaining: Int?
    let expiresAt: Date?
    let createdAt: Date?
    let createdBy: UUID

    init(from invite: Invite) {
        self.id = invite.id!
        self.code = invite.code
        self.usesRemaining = invite.usesRemaining
        self.expiresAt = invite.expiresAt
        self.createdAt = invite.createdAt
        self.createdBy = invite.$createdBy.id
    }
}

/// Simple success response
struct SuccessResponse: Content {
    let success: Bool
    let message: String?

    init(message: String? = nil) {
        self.success = true
        self.message = message
    }
}

/// Error response
struct ErrorResponse: Content {
    let error: Bool
    let reason: String

    init(reason: String) {
        self.error = true
        self.reason = reason
    }
}
