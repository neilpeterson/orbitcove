import Fluent
import Foundation

/// Post type
enum PostType: String, Codable {
    case text
    case photo
    case announcement
    case poll
    case eventShare = "event_share"
}

/// Poll configuration stored as JSON
struct PollData: Codable {
    var question: String
    var options: [String]
    var allowMultiple: Bool
    var closesAt: Date?
}

final class Post: Model, @unchecked Sendable {
    static let schema = "posts"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "community_id")
    var community: Community

    @Parent(key: "author_id")
    var author: User

    @Enum(key: "type")
    var type: PostType

    @OptionalField(key: "content")
    var content: String?

    @Field(key: "media_urls")
    var mediaUrls: [String]

    @Field(key: "is_pinned")
    var isPinned: Bool

    @Field(key: "is_announcement")
    var isAnnouncement: Bool

    @OptionalParent(key: "linked_event_id")
    var linkedEvent: Event?

    @OptionalField(key: "poll_data")
    var pollData: PollData?

    @OptionalField(key: "editable_until")
    var editableUntil: Date?

    @Field(key: "reaction_counts")
    var reactionCounts: [String: Int]

    @Field(key: "comment_count")
    var commentCount: Int

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @OptionalField(key: "deleted_at")
    var deletedAt: Date?

    // Relationships
    @Children(for: \.$post)
    var reactions: [Reaction]

    @Children(for: \.$post)
    var comments: [Comment]

    @Children(for: \.$post)
    var pollVotes: [PollVote]

    init() {}

    init(
        id: UUID? = nil,
        communityId: UUID,
        authorId: UUID,
        type: PostType = .text,
        content: String? = nil,
        mediaUrls: [String] = [],
        isPinned: Bool = false,
        isAnnouncement: Bool = false,
        linkedEventId: UUID? = nil,
        pollData: PollData? = nil
    ) {
        self.id = id
        self.$community.id = communityId
        self.$author.id = authorId
        self.type = type
        self.content = content
        self.mediaUrls = mediaUrls
        self.isPinned = isPinned
        self.isAnnouncement = isAnnouncement
        if let linkedEventId = linkedEventId {
            self.$linkedEvent.id = linkedEventId
        }
        self.pollData = pollData
        self.reactionCounts = [:]
        self.commentCount = 0
    }
}
