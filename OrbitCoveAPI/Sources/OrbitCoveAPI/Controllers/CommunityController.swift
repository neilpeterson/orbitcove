import Fluent
import Vapor

struct CommunityController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("api", "v1", "communities")

        // Community CRUD
        api.post(use: create)
        api.get(":communityId", use: get)
        api.patch(":communityId", use: update)
        api.delete(":communityId", use: delete)

        // Join community
        api.post(":communityId", "join", use: join)

        // Members
        api.get(":communityId", "members", use: getMembers)
        api.patch(":communityId", "members", ":userId", use: updateMember)
        api.delete(":communityId", "members", ":userId", use: removeMember)

        // Invites
        api.get(":communityId", "invites", use: getInvites)
        api.post(":communityId", "invites", use: createInvite)
        api.delete(":communityId", "invites", ":inviteId", use: deleteInvite)
    }

    // MARK: - Community CRUD

    /// Create a new community (POST /api/v1/communities)
    @Sendable
    func create(req: Request) async throws -> CommunityDetailResponse {
        let user = try await getAuthenticatedUser(req: req)
        let input = try req.content.decode(CreateCommunityRequest.self)

        let community = Community(
            name: input.name,
            description: input.description,
            iconUrl: input.iconUrl,
            createdById: user.id!
        )

        try await community.save(on: req.db)

        // Add creator as admin member
        let member = Member(
            communityId: community.id!,
            userId: user.id!,
            role: .admin
        )
        try await member.save(on: req.db)

        return CommunityDetailResponse(from: community)
    }

    /// Get community details (GET /api/v1/communities/:communityId)
    @Sendable
    func get(req: Request) async throws -> CommunityDetailResponse {
        let user = try await getAuthenticatedUser(req: req)
        let community = try await getCommunity(req: req)

        // Verify user is a member
        try await verifyMembership(user: user, community: community, on: req.db)

        return CommunityDetailResponse(from: community)
    }

    /// Update community (PATCH /api/v1/communities/:communityId)
    @Sendable
    func update(req: Request) async throws -> CommunityDetailResponse {
        let user = try await getAuthenticatedUser(req: req)
        let community = try await getCommunity(req: req)

        // Verify user is an admin
        try await verifyAdmin(user: user, community: community, on: req.db)

        let input = try req.content.decode(UpdateCommunityRequest.self)

        if let name = input.name {
            community.name = name
        }
        if let description = input.description {
            community.description = description
        }
        if let iconUrl = input.iconUrl {
            community.iconUrl = iconUrl
        }
        if let settings = input.settings {
            community.settings = settings
        }

        try await community.save(on: req.db)
        return CommunityDetailResponse(from: community)
    }

    /// Delete community (DELETE /api/v1/communities/:communityId)
    @Sendable
    func delete(req: Request) async throws -> SuccessResponse {
        let user = try await getAuthenticatedUser(req: req)
        let community = try await getCommunity(req: req)

        // Verify user is an admin
        try await verifyAdmin(user: user, community: community, on: req.db)

        // Soft delete
        community.deletedAt = Date()
        try await community.save(on: req.db)

        return SuccessResponse(message: "Community deleted")
    }

    // MARK: - Join Community

    /// Join community via invite code (POST /api/v1/communities/:communityId/join)
    @Sendable
    func join(req: Request) async throws -> MemberResponse {
        let user = try await getAuthenticatedUser(req: req)
        let input = try req.content.decode(JoinCommunityRequest.self)

        // Find invite by code
        guard let invite = try await Invite.query(on: req.db)
            .filter(\.$code == input.code.uppercased())
            .with(\.$community)
            .first() else {
            throw Abort(.notFound, reason: "Invalid invite code")
        }

        let community = invite.community

        // Check if invite is valid
        if let expiresAt = invite.expiresAt, expiresAt < Date() {
            throw Abort(.gone, reason: "Invite has expired")
        }

        if let usesRemaining = invite.usesRemaining, usesRemaining <= 0 {
            throw Abort(.gone, reason: "Invite has no uses remaining")
        }

        // Check if already a member
        let existingMember = try await Member.query(on: req.db)
            .filter(\.$community.$id == community.id!)
            .filter(\.$user.$id == user.id!)
            .filter(\.$leftAt == nil)
            .first()
        if existingMember != nil {
            throw Abort(.conflict, reason: "Already a member of this community")
        }

        // Create membership
        let member = Member(
            communityId: community.id!,
            userId: user.id!,
            role: .member,
            invitedById: invite.$createdBy.id
        )
        try await member.save(on: req.db)

        // Update community member count
        community.memberCount += 1
        try await community.save(on: req.db)

        // Decrement invite uses if limited
        if var usesRemaining = invite.usesRemaining {
            usesRemaining -= 1
            invite.usesRemaining = usesRemaining
            try await invite.save(on: req.db)
        }

        return MemberResponse(from: member, user: user)
    }

    // MARK: - Members

    /// Get community members (GET /api/v1/communities/:communityId/members)
    @Sendable
    func getMembers(req: Request) async throws -> [MemberResponse] {
        let user = try await getAuthenticatedUser(req: req)
        let community = try await getCommunity(req: req)

        // Verify user is a member
        try await verifyMembership(user: user, community: community, on: req.db)

        let members = try await Member.query(on: req.db)
            .filter(\.$community.$id == community.id!)
            .filter(\.$leftAt == nil)
            .with(\.$user)
            .all()

        return members.map { MemberResponse(from: $0, user: $0.user) }
    }

    /// Update member role (PATCH /api/v1/communities/:communityId/members/:userId)
    @Sendable
    func updateMember(req: Request) async throws -> MemberResponse {
        let currentUser = try await getAuthenticatedUser(req: req)
        let community = try await getCommunity(req: req)

        // Verify current user is an admin
        try await verifyAdmin(user: currentUser, community: community, on: req.db)

        guard let targetUserId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }

        guard let member = try await Member.query(on: req.db)
            .filter(\.$community.$id == community.id!)
            .filter(\.$user.$id == targetUserId)
            .filter(\.$leftAt == nil)
            .with(\.$user)
            .first() else {
            throw Abort(.notFound, reason: "Member not found")
        }

        let input = try req.content.decode(UpdateMemberRequest.self)

        if let roleString = input.role, let role = MemberRole(rawValue: roleString) {
            member.role = role
        }
        if let nickname = input.nickname {
            member.nickname = nickname
        }

        try await member.save(on: req.db)
        return MemberResponse(from: member, user: member.user)
    }

    /// Remove member (DELETE /api/v1/communities/:communityId/members/:userId)
    @Sendable
    func removeMember(req: Request) async throws -> SuccessResponse {
        let currentUser = try await getAuthenticatedUser(req: req)
        let community = try await getCommunity(req: req)

        guard let targetUserId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }

        // User can remove themselves, or admin can remove others
        let isSelf = targetUserId == currentUser.id
        if !isSelf {
            try await verifyAdmin(user: currentUser, community: community, on: req.db)
        }

        guard let member = try await Member.query(on: req.db)
            .filter(\.$community.$id == community.id!)
            .filter(\.$user.$id == targetUserId)
            .filter(\.$leftAt == nil)
            .first() else {
            throw Abort(.notFound, reason: "Member not found")
        }

        // Soft delete - set left_at
        member.leftAt = Date()
        try await member.save(on: req.db)

        // Update community member count
        community.memberCount -= 1
        try await community.save(on: req.db)

        return SuccessResponse(message: isSelf ? "Left community" : "Member removed")
    }

    // MARK: - Invites

    /// Get community invites (GET /api/v1/communities/:communityId/invites)
    @Sendable
    func getInvites(req: Request) async throws -> [InviteResponse] {
        let user = try await getAuthenticatedUser(req: req)
        let community = try await getCommunity(req: req)

        // Verify user is an admin
        try await verifyAdmin(user: user, community: community, on: req.db)

        let invites = try await Invite.query(on: req.db)
            .filter(\.$community.$id == community.id!)
            .all()

        return invites.map { InviteResponse(from: $0) }
    }

    /// Create invite (POST /api/v1/communities/:communityId/invites)
    @Sendable
    func createInvite(req: Request) async throws -> InviteResponse {
        let user = try await getAuthenticatedUser(req: req)
        let community = try await getCommunity(req: req)

        // Verify user is an admin
        try await verifyAdmin(user: user, community: community, on: req.db)

        let input = try? req.content.decode(CreateInviteRequest.self)

        var expiresAt: Date? = nil
        if let hours = input?.expiresInHours {
            expiresAt = Date().addingTimeInterval(TimeInterval(hours * 3600))
        }

        let invite = Invite(
            communityId: community.id!,
            code: Invite.generateCode(),
            createdById: user.id!,
            usesRemaining: input?.usesRemaining,
            expiresAt: expiresAt
        )

        try await invite.save(on: req.db)
        return InviteResponse(from: invite)
    }

    /// Delete invite (DELETE /api/v1/communities/:communityId/invites/:inviteId)
    @Sendable
    func deleteInvite(req: Request) async throws -> SuccessResponse {
        let user = try await getAuthenticatedUser(req: req)
        let community = try await getCommunity(req: req)

        // Verify user is an admin
        try await verifyAdmin(user: user, community: community, on: req.db)

        guard let inviteId = req.parameters.get("inviteId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid invite ID")
        }

        guard let invite = try await Invite.query(on: req.db)
            .filter(\.$id == inviteId)
            .filter(\.$community.$id == community.id!)
            .first() else {
            throw Abort(.notFound, reason: "Invite not found")
        }

        try await invite.delete(on: req.db)
        return SuccessResponse(message: "Invite deleted")
    }

    // MARK: - Helper Methods

    /// Get authenticated user from request
    private func getAuthenticatedUser(req: Request) async throws -> User {
        guard let userIdString = req.headers.first(name: "X-User-ID"),
              let userId = UUID(uuidString: userIdString) else {
            throw Abort(.unauthorized, reason: "Missing or invalid X-User-ID header")
        }

        guard let user = try await User.find(userId, on: req.db) else {
            throw Abort(.unauthorized, reason: "User not found")
        }

        if user.deletedAt != nil {
            throw Abort(.unauthorized, reason: "Account has been deleted")
        }

        return user
    }

    /// Get community from route parameter
    private func getCommunity(req: Request) async throws -> Community {
        guard let communityId = req.parameters.get("communityId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid community ID")
        }

        guard let community = try await Community.find(communityId, on: req.db) else {
            throw Abort(.notFound, reason: "Community not found")
        }

        if community.deletedAt != nil {
            throw Abort(.notFound, reason: "Community not found")
        }

        return community
    }

    /// Verify user is a member of the community
    private func verifyMembership(user: User, community: Community, on db: any Database) async throws {
        guard let _ = try await Member.query(on: db)
            .filter(\.$community.$id == community.id!)
            .filter(\.$user.$id == user.id!)
            .filter(\.$leftAt == nil)
            .first() else {
            throw Abort(.forbidden, reason: "Not a member of this community")
        }
    }

    /// Verify user is an admin of the community
    private func verifyAdmin(user: User, community: Community, on db: any Database) async throws {
        guard let member = try await Member.query(on: db)
            .filter(\.$community.$id == community.id!)
            .filter(\.$user.$id == user.id!)
            .filter(\.$leftAt == nil)
            .first() else {
            throw Abort(.forbidden, reason: "Not a member of this community")
        }

        if member.role != .admin {
            throw Abort(.forbidden, reason: "Admin access required")
        }
    }
}
