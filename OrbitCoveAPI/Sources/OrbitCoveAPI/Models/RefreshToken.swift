import Fluent
import Foundation

final class RefreshToken: Model, @unchecked Sendable {
    static let schema = "refresh_tokens"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "token_hash")
    var tokenHash: String

    @OptionalField(key: "device_name")
    var deviceName: String?

    @Field(key: "expires_at")
    var expiresAt: Date

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @OptionalField(key: "revoked_at")
    var revokedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        userId: UUID,
        tokenHash: String,
        deviceName: String? = nil,
        expiresAt: Date
    ) {
        self.id = id
        self.$user.id = userId
        self.tokenHash = tokenHash
        self.deviceName = deviceName
        self.expiresAt = expiresAt
    }

    /// Check if token is valid (not expired and not revoked)
    var isValid: Bool {
        revokedAt == nil && expiresAt > Date()
    }
}
