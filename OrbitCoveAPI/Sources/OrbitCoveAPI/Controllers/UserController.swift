import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("api", "v1")

        // User registration (from Apple Sign In)
        api.post("users", use: create)

        // Current user endpoints
        let me = api.grouped("me")
        me.get(use: getCurrentUser)
        me.patch(use: updateCurrentUser)
        me.delete(use: deleteCurrentUser)
        me.get("communities", use: getUserCommunities)

        // Family members
        me.get("family-members", use: getFamilyMembers)
        me.post("family-members", use: createFamilyMember)
        me.patch("family-members", ":familyMemberId", use: updateFamilyMember)
        me.delete("family-members", ":familyMemberId", use: deleteFamilyMember)
    }

    // MARK: - User CRUD

    /// Create a new user (POST /api/v1/users)
    @Sendable
    func create(req: Request) async throws -> UserResponse {
        let input = try req.content.decode(CreateUserRequest.self)

        // Check if user already exists
        if let existing = try await User.query(on: req.db)
            .filter(\.$appleId == input.appleId)
            .first() {
            return UserResponse(from: existing)
        }

        let user = User(
            appleId: input.appleId,
            email: input.email,
            displayName: input.displayName
        )

        try await user.save(on: req.db)
        return UserResponse(from: user)
    }

    /// Get current user (GET /api/v1/me)
    @Sendable
    func getCurrentUser(req: Request) async throws -> UserResponse {
        let user = try await getAuthenticatedUser(req: req)
        return UserResponse(from: user)
    }

    /// Update current user (PATCH /api/v1/me)
    @Sendable
    func updateCurrentUser(req: Request) async throws -> UserResponse {
        let user = try await getAuthenticatedUser(req: req)
        let input = try req.content.decode(UpdateUserRequest.self)

        if let displayName = input.displayName {
            user.displayName = displayName
        }
        if let avatarUrl = input.avatarUrl {
            user.avatarUrl = avatarUrl
        }

        try await user.save(on: req.db)
        return UserResponse(from: user)
    }

    /// Delete current user (DELETE /api/v1/me)
    @Sendable
    func deleteCurrentUser(req: Request) async throws -> SuccessResponse {
        let user = try await getAuthenticatedUser(req: req)

        // Soft delete - set deleted_at
        user.deletedAt = Date()
        try await user.save(on: req.db)

        return SuccessResponse(message: "Account deleted")
    }

    /// Get user's communities (GET /api/v1/me/communities)
    @Sendable
    func getUserCommunities(req: Request) async throws -> [CommunityMembershipResponse] {
        let user = try await getAuthenticatedUser(req: req)

        let memberships = try await Member.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .filter(\.$leftAt == nil)
            .with(\.$community)
            .all()

        return memberships.map { member in
            CommunityMembershipResponse(from: member, community: member.community)
        }
    }

    // MARK: - Family Members

    /// Get family members (GET /api/v1/me/family-members)
    @Sendable
    func getFamilyMembers(req: Request) async throws -> [FamilyMemberResponse] {
        let user = try await getAuthenticatedUser(req: req)

        let members = try await FamilyMember.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .all()

        return members.map { FamilyMemberResponse(from: $0) }
    }

    /// Create family member (POST /api/v1/me/family-members)
    @Sendable
    func createFamilyMember(req: Request) async throws -> FamilyMemberResponse {
        let user = try await getAuthenticatedUser(req: req)
        let input = try req.content.decode(CreateFamilyMemberRequest.self)

        let member = FamilyMember(
            userId: user.id!,
            name: input.name,
            avatarUrl: input.avatarUrl
        )

        try await member.save(on: req.db)
        return FamilyMemberResponse(from: member)
    }

    /// Update family member (PATCH /api/v1/me/family-members/:familyMemberId)
    @Sendable
    func updateFamilyMember(req: Request) async throws -> FamilyMemberResponse {
        let user = try await getAuthenticatedUser(req: req)
        guard let familyMemberId = req.parameters.get("familyMemberId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid family member ID")
        }

        guard let member = try await FamilyMember.query(on: req.db)
            .filter(\.$id == familyMemberId)
            .filter(\.$user.$id == user.id!)
            .first() else {
            throw Abort(.notFound, reason: "Family member not found")
        }

        let input = try req.content.decode(UpdateFamilyMemberRequest.self)

        if let name = input.name {
            member.name = name
        }
        if let avatarUrl = input.avatarUrl {
            member.avatarUrl = avatarUrl
        }

        try await member.save(on: req.db)
        return FamilyMemberResponse(from: member)
    }

    /// Delete family member (DELETE /api/v1/me/family-members/:familyMemberId)
    @Sendable
    func deleteFamilyMember(req: Request) async throws -> SuccessResponse {
        let user = try await getAuthenticatedUser(req: req)
        guard let familyMemberId = req.parameters.get("familyMemberId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid family member ID")
        }

        guard let member = try await FamilyMember.query(on: req.db)
            .filter(\.$id == familyMemberId)
            .filter(\.$user.$id == user.id!)
            .first() else {
            throw Abort(.notFound, reason: "Family member not found")
        }

        try await member.delete(on: req.db)
        return SuccessResponse(message: "Family member deleted")
    }

    // MARK: - Helper Methods

    /// Get authenticated user from request
    /// TODO: Replace with actual auth middleware
    private func getAuthenticatedUser(req: Request) async throws -> User {
        // For now, use a header-based user ID (will be replaced with JWT auth)
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
}
