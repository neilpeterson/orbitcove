import Fluent
import Foundation

/// Reaction type
enum ReactionType: String, Codable {
    case like
    case love
    case laugh
    case celebrate
}

final class Reaction: Model, @unchecked Sendable {
    static let schema = "reactions"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "post_id")
    var post: Post

    @Parent(key: "user_id")
    var user: User

    @Enum(key: "type")
    var type: ReactionType

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        postId: UUID,
        userId: UUID,
        type: ReactionType
    ) {
        self.id = id
        self.$post.id = postId
        self.$user.id = userId
        self.type = type
    }
}
