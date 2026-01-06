import Fluent
import Vapor

// MARK: - Request DTOs

/// Create user request (from Apple Sign In)
struct CreateUserRequest: Content {
    let appleId: String
    let email: String
    let displayName: String
}

/// Update user profile request
struct UpdateUserRequest: Content {
    var displayName: String?
    var avatarUrl: String?
}

/// Create family member request
struct CreateFamilyMemberRequest: Content {
    let name: String
    var avatarUrl: String?
}

/// Update family member request
struct UpdateFamilyMemberRequest: Content {
    var name: String?
    var avatarUrl: String?
}

// MARK: - Response DTOs

/// User response (safe for API output)
struct UserResponse: Content {
    let id: UUID
    let email: String
    let displayName: String
    let avatarUrl: String?
    let createdAt: Date?

    init(from user: User) {
        self.id = user.id!
        self.email = user.email
        self.displayName = user.displayName
        self.avatarUrl = user.avatarUrl
        self.createdAt = user.createdAt
    }
}

/// Family member response
struct FamilyMemberResponse: Content {
    let id: UUID
    let name: String
    let avatarUrl: String?
    let createdAt: Date?

    init(from member: FamilyMember) {
        self.id = member.id!
        self.name = member.name
        self.avatarUrl = member.avatarUrl
        self.createdAt = member.createdAt
    }
}

/// User with their communities
struct UserWithCommunitiesResponse: Content {
    let user: UserResponse
    let communities: [CommunityMembershipResponse]
}

/// Community membership info for a user
struct CommunityMembershipResponse: Content {
    let communityId: UUID
    let communityName: String
    let role: String
    let joinedAt: Date?

    init(from member: Member, community: Community) {
        self.communityId = community.id!
        self.communityName = community.name
        self.role = member.role.rawValue
        self.joinedAt = member.joinedAt
    }
}
