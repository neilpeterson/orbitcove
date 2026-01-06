import Fluent
import Foundation

final class User: Model, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "apple_id")
    var appleId: String

    @Field(key: "email")
    var email: String

    @Field(key: "display_name")
    var displayName: String

    @OptionalField(key: "avatar_url")
    var avatarUrl: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @OptionalField(key: "deleted_at")
    var deletedAt: Date?

    // Relationships
    @Children(for: \.$user)
    var familyMembers: [FamilyMember]

    @Children(for: \.$user)
    var memberships: [Member]

    init() {}

    init(
        id: UUID? = nil,
        appleId: String,
        email: String,
        displayName: String,
        avatarUrl: String? = nil
    ) {
        self.id = id
        self.appleId = appleId
        self.email = email
        self.displayName = displayName
        self.avatarUrl = avatarUrl
    }
}
