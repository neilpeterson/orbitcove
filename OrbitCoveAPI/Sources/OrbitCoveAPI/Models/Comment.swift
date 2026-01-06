import Fluent
import Foundation

final class Comment: Model, @unchecked Sendable {
    static let schema = "comments"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "post_id")
    var post: Post

    @Parent(key: "author_id")
    var author: User

    @OptionalParent(key: "parent_id")
    var parent: Comment?

    @Field(key: "content")
    var content: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @OptionalField(key: "deleted_at")
    var deletedAt: Date?

    // Relationships
    @Children(for: \.$parent)
    var replies: [Comment]

    init() {}

    init(
        id: UUID? = nil,
        postId: UUID,
        authorId: UUID,
        parentId: UUID? = nil,
        content: String
    ) {
        self.id = id
        self.$post.id = postId
        self.$author.id = authorId
        if let parentId = parentId {
            self.$parent.id = parentId
        }
        self.content = content
    }
}
