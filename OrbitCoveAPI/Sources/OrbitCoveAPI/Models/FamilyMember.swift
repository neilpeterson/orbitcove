import Fluent
import Foundation

final class FamilyMember: Model, @unchecked Sendable {
    static let schema = "family_members"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "name")
    var name: String

    @OptionalField(key: "avatar_url")
    var avatarUrl: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        userId: UUID,
        name: String,
        avatarUrl: String? = nil
    ) {
        self.id = id
        self.$user.id = userId
        self.name = name
        self.avatarUrl = avatarUrl
    }
}
