import Fluent
import Foundation

/// Audit log metadata
struct AuditMetadata: Codable {
    var previousValue: String?
    var newValue: String?
    var reason: String?
    var additionalInfo: [String: String]?
}

final class AuditLog: Model, @unchecked Sendable {
    static let schema = "audit_log"

    @ID(key: .id)
    var id: UUID?

    @OptionalParent(key: "community_id")
    var community: Community?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "action")
    var action: String

    @OptionalField(key: "target_type")
    var targetType: String?

    @OptionalField(key: "target_id")
    var targetId: UUID?

    @Field(key: "metadata")
    var metadata: AuditMetadata

    @OptionalField(key: "ip_address")
    var ipAddress: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        communityId: UUID? = nil,
        userId: UUID,
        action: String,
        targetType: String? = nil,
        targetId: UUID? = nil,
        metadata: AuditMetadata = AuditMetadata(),
        ipAddress: String? = nil
    ) {
        self.id = id
        if let communityId = communityId {
            self.$community.id = communityId
        }
        self.$user.id = userId
        self.action = action
        self.targetType = targetType
        self.targetId = targetId
        self.metadata = metadata
        self.ipAddress = ipAddress
    }
}
