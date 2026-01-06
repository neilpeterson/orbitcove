import Fluent
import Foundation

final class Invite: Model, @unchecked Sendable {
    static let schema = "invites"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "community_id")
    var community: Community

    @Field(key: "code")
    var code: String

    @Parent(key: "created_by")
    var createdBy: User

    @OptionalField(key: "uses_remaining")
    var usesRemaining: Int?

    @OptionalField(key: "expires_at")
    var expiresAt: Date?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        communityId: UUID,
        code: String,
        createdById: UUID,
        usesRemaining: Int? = nil,
        expiresAt: Date? = nil
    ) {
        self.id = id
        self.$community.id = communityId
        self.code = code
        self.$createdBy.id = createdById
        self.usesRemaining = usesRemaining
        self.expiresAt = expiresAt
    }

    /// Generate a random 6-character invite code
    static func generateCode() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
}
