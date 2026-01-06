import Fluent
import Foundation

/// Media type
enum MediaType: String, Codable {
    case image
    case video
    case document
}

final class Media: Model, @unchecked Sendable {
    static let schema = "media"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "community_id")
    var community: Community

    @Parent(key: "uploaded_by")
    var uploadedBy: User

    @Enum(key: "type")
    var type: MediaType

    @Field(key: "filename")
    var filename: String

    @Field(key: "mime_type")
    var mimeType: String

    @Field(key: "size_bytes")
    var sizeBytes: Int

    @Field(key: "storage_path")
    var storagePath: String

    @OptionalField(key: "thumbnail_path")
    var thumbnailPath: String?

    @OptionalField(key: "width")
    var width: Int?

    @OptionalField(key: "height")
    var height: Int?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        communityId: UUID,
        uploadedById: UUID,
        type: MediaType,
        filename: String,
        mimeType: String,
        sizeBytes: Int,
        storagePath: String,
        thumbnailPath: String? = nil,
        width: Int? = nil,
        height: Int? = nil
    ) {
        self.id = id
        self.$community.id = communityId
        self.$uploadedBy.id = uploadedById
        self.type = type
        self.filename = filename
        self.mimeType = mimeType
        self.sizeBytes = sizeBytes
        self.storagePath = storagePath
        self.thumbnailPath = thumbnailPath
        self.width = width
        self.height = height
    }
}
