import Fluent
import Foundation

final class PollVote: Model, @unchecked Sendable {
    static let schema = "poll_votes"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "post_id")
    var post: Post

    @Parent(key: "user_id")
    var user: User

    @Field(key: "option_index")
    var optionIndex: Int

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        postId: UUID,
        userId: UUID,
        optionIndex: Int
    ) {
        self.id = id
        self.$post.id = postId
        self.$user.id = userId
        self.optionIndex = optionIndex
    }
}
