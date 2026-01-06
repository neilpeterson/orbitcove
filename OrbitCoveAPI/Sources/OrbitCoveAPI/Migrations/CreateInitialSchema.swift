import Fluent

struct CreateInitialSchema: AsyncMigration {
    func prepare(on database: any Database) async throws {
        // Create enum types first (for PostgreSQL)
        _ = try await database.enum("member_role")
            .case("admin")
            .case("member")
            .create()

        _ = try await database.enum("subscription_status")
            .case("free")
            .case("active")
            .case("past_due")
            .case("canceled")
            .create()

        _ = try await database.enum("rsvp_status")
            .case("yes")
            .case("no")
            .case("maybe")
            .create()

        _ = try await database.enum("event_category")
            .case("practice")
            .case("game")
            .case("meeting")
            .case("social")
            .case("other")
            .create()

        _ = try await database.enum("post_type")
            .case("text")
            .case("photo")
            .case("announcement")
            .case("poll")
            .case("event_share")
            .create()

        _ = try await database.enum("reaction_type")
            .case("like")
            .case("love")
            .case("laugh")
            .case("celebrate")
            .create()

        _ = try await database.enum("transaction_type")
            .case("expense")
            .case("settlement")
            .case("dues")
            .create()

        _ = try await database.enum("expense_category")
            .case("equipment")
            .case("food")
            .case("travel")
            .case("dues")
            .case("other")
            .create()

        _ = try await database.enum("media_type")
            .case("image")
            .case("video")
            .case("document")
            .create()

        _ = try await database.enum("notification_type")
            .case("event_reminder")
            .case("new_post")
            .case("mention")
            .case("rsvp_request")
            .case("payment_request")
            .create()

        // Get enum references
        let memberRole = try await database.enum("member_role").read()
        let subscriptionStatus = try await database.enum("subscription_status").read()
        let rsvpStatus = try await database.enum("rsvp_status").read()
        let eventCategory = try await database.enum("event_category").read()
        let postType = try await database.enum("post_type").read()
        let reactionType = try await database.enum("reaction_type").read()
        let transactionType = try await database.enum("transaction_type").read()
        let expenseCategory = try await database.enum("expense_category").read()
        let mediaType = try await database.enum("media_type").read()
        let notificationType = try await database.enum("notification_type").read()

        // ============================================
        // USERS
        // ============================================
        try await database.schema("users")
            .id()
            .field("apple_id", .string, .required)
            .field("email", .string, .required)
            .field("display_name", .string, .required)
            .field("avatar_url", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .unique(on: "apple_id")
            .create()

        // ============================================
        // FAMILY MEMBERS
        // ============================================
        try await database.schema("family_members")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("name", .string, .required)
            .field("avatar_url", .string)
            .field("created_at", .datetime)
            .create()

        // ============================================
        // COMMUNITIES
        // ============================================
        try await database.schema("communities")
            .id()
            .field("name", .string, .required)
            .field("description", .string)
            .field("icon_url", .string)
            .field("created_by", .uuid, .required, .references("users", "id"))
            .field("member_count", .int, .required, .sql(.default(1)))
            .field("subscription_status", subscriptionStatus, .required, .sql(.default("free")))
            .field("subscription_expires_at", .datetime)
            .field("stripe_customer_id", .string)
            .field("stripe_subscription_id", .string)
            .field("settings", .json, .required, .sql(.default("{}")))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()

        // ============================================
        // MEMBERS
        // ============================================
        try await database.schema("members")
            .id()
            .field("community_id", .uuid, .required, .references("communities", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("role", memberRole, .required, .sql(.default("member")))
            .field("nickname", .string)
            .field("notification_prefs", .json, .required, .sql(.default("{}")))
            .field("joined_at", .datetime)
            .field("invited_by", .uuid, .references("users", "id"))
            .field("left_at", .datetime)
            .unique(on: "community_id", "user_id")
            .create()

        // ============================================
        // INVITES
        // ============================================
        try await database.schema("invites")
            .id()
            .field("community_id", .uuid, .required, .references("communities", "id", onDelete: .cascade))
            .field("code", .string, .required)
            .field("created_by", .uuid, .required, .references("users", "id"))
            .field("uses_remaining", .int)
            .field("expires_at", .datetime)
            .field("created_at", .datetime)
            .unique(on: "code")
            .create()

        // ============================================
        // EVENTS
        // ============================================
        try await database.schema("events")
            .id()
            .field("community_id", .uuid, .required, .references("communities", "id", onDelete: .cascade))
            .field("created_by", .uuid, .required, .references("users", "id"))
            .field("title", .string, .required)
            .field("description", .string)
            .field("starts_at", .datetime, .required)
            .field("ends_at", .datetime)
            .field("all_day", .bool, .required, .sql(.default(false)))
            .field("location_name", .string)
            .field("location_lat", .double)
            .field("location_lng", .double)
            .field("location_address", .string)
            .field("category", eventCategory, .required, .sql(.default("other")))
            .field("recurrence_rule", .string)
            .field("recurrence_parent_id", .uuid, .references("events", "id"))
            .field("attachments", .json, .required, .sql(.default("[]")))
            .field("rsvp_deadline", .datetime)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()

        // ============================================
        // RSVPS
        // ============================================
        try await database.schema("rsvps")
            .id()
            .field("event_id", .uuid, .required, .references("events", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("family_member_id", .uuid, .references("family_members", "id", onDelete: .cascade))
            .field("status", rsvpStatus, .required)
            .field("plus_ones", .int, .required, .sql(.default(0)))
            .field("note", .string)
            .field("responded_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "event_id", "user_id", "family_member_id")
            .create()

        // ============================================
        // POSTS
        // ============================================
        try await database.schema("posts")
            .id()
            .field("community_id", .uuid, .required, .references("communities", "id", onDelete: .cascade))
            .field("author_id", .uuid, .required, .references("users", "id"))
            .field("type", postType, .required, .sql(.default("text")))
            .field("content", .string)
            .field("media_urls", .json, .required, .sql(.default("[]")))
            .field("is_pinned", .bool, .required, .sql(.default(false)))
            .field("is_announcement", .bool, .required, .sql(.default(false)))
            .field("linked_event_id", .uuid, .references("events", "id"))
            .field("poll_data", .json)
            .field("editable_until", .datetime)
            .field("reaction_counts", .json, .required, .sql(.default("{}")))
            .field("comment_count", .int, .required, .sql(.default(0)))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()

        // ============================================
        // REACTIONS
        // ============================================
        try await database.schema("reactions")
            .id()
            .field("post_id", .uuid, .required, .references("posts", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("type", reactionType, .required)
            .field("created_at", .datetime)
            .unique(on: "post_id", "user_id")
            .create()

        // ============================================
        // COMMENTS
        // ============================================
        try await database.schema("comments")
            .id()
            .field("post_id", .uuid, .required, .references("posts", "id", onDelete: .cascade))
            .field("author_id", .uuid, .required, .references("users", "id"))
            .field("parent_id", .uuid, .references("comments", "id"))
            .field("content", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()

        // ============================================
        // POLL VOTES
        // ============================================
        try await database.schema("poll_votes")
            .id()
            .field("post_id", .uuid, .required, .references("posts", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("option_index", .int, .required)
            .field("created_at", .datetime)
            .create()

        // ============================================
        // TRANSACTIONS
        // ============================================
        try await database.schema("transactions")
            .id()
            .field("community_id", .uuid, .required, .references("communities", "id", onDelete: .cascade))
            .field("created_by", .uuid, .required, .references("users", "id"))
            .field("type", transactionType, .required)
            .field("description", .string, .required)
            .field("total_amount", .int, .required)
            .field("currency", .string, .required, .sql(.default("USD")))
            .field("paid_by", .uuid, .required, .references("users", "id"))
            .field("category", expenseCategory, .required, .sql(.default("other")))
            .field("receipt_url", .string)
            .field("linked_event_id", .uuid, .references("events", "id"))
            .field("transaction_date", .date, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()

        // ============================================
        // SPLITS
        // ============================================
        try await database.schema("splits")
            .id()
            .field("transaction_id", .uuid, .required, .references("transactions", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("amount", .int, .required)
            .field("is_settled", .bool, .required, .sql(.default(false)))
            .field("settled_at", .datetime)
            .field("settled_via", .string)
            .create()

        // ============================================
        // DUES
        // ============================================
        try await database.schema("dues")
            .id()
            .field("community_id", .uuid, .required, .references("communities", "id", onDelete: .cascade))
            .field("name", .string, .required)
            .field("amount", .int, .required)
            .field("due_date", .date, .required)
            .field("is_active", .bool, .required, .sql(.default(true)))
            .field("created_by", .uuid, .required, .references("users", "id"))
            .field("created_at", .datetime)
            .create()

        // ============================================
        // DUES PAYMENTS
        // ============================================
        try await database.schema("dues_payments")
            .id()
            .field("dues_id", .uuid, .required, .references("dues", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("amount_paid", .int, .required)
            .field("paid_at", .datetime)
            .field("recorded_by", .uuid, .required, .references("users", "id"))
            .field("payment_method", .string)
            .field("notes", .string)
            .create()

        // ============================================
        // MEDIA
        // ============================================
        try await database.schema("media")
            .id()
            .field("community_id", .uuid, .required, .references("communities", "id", onDelete: .cascade))
            .field("uploaded_by", .uuid, .required, .references("users", "id"))
            .field("type", mediaType, .required)
            .field("filename", .string, .required)
            .field("mime_type", .string, .required)
            .field("size_bytes", .int, .required)
            .field("storage_path", .string, .required)
            .field("thumbnail_path", .string)
            .field("width", .int)
            .field("height", .int)
            .field("created_at", .datetime)
            .create()

        // ============================================
        // NOTIFICATIONS
        // ============================================
        try await database.schema("notifications")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("community_id", .uuid, .references("communities", "id", onDelete: .cascade))
            .field("type", notificationType, .required)
            .field("title", .string, .required)
            .field("body", .string, .required)
            .field("data", .json, .required, .sql(.default("{}")))
            .field("read_at", .datetime)
            .field("created_at", .datetime)
            .create()

        // ============================================
        // AUDIT LOG
        // ============================================
        try await database.schema("audit_log")
            .id()
            .field("community_id", .uuid, .references("communities", "id", onDelete: .setNull))
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("action", .string, .required)
            .field("target_type", .string)
            .field("target_id", .uuid)
            .field("metadata", .json, .required, .sql(.default("{}")))
            .field("ip_address", .string)
            .field("created_at", .datetime)
            .create()

        // ============================================
        // REFRESH TOKENS
        // ============================================
        try await database.schema("refresh_tokens")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("token_hash", .string, .required)
            .field("device_name", .string)
            .field("expires_at", .datetime, .required)
            .field("created_at", .datetime)
            .field("revoked_at", .datetime)
            .unique(on: "token_hash")
            .create()
    }

    func revert(on database: any Database) async throws {
        // Drop tables in reverse order of creation (to handle foreign keys)
        try await database.schema("refresh_tokens").delete()
        try await database.schema("audit_log").delete()
        try await database.schema("notifications").delete()
        try await database.schema("media").delete()
        try await database.schema("dues_payments").delete()
        try await database.schema("dues").delete()
        try await database.schema("splits").delete()
        try await database.schema("transactions").delete()
        try await database.schema("poll_votes").delete()
        try await database.schema("comments").delete()
        try await database.schema("reactions").delete()
        try await database.schema("posts").delete()
        try await database.schema("rsvps").delete()
        try await database.schema("events").delete()
        try await database.schema("invites").delete()
        try await database.schema("members").delete()
        try await database.schema("communities").delete()
        try await database.schema("family_members").delete()
        try await database.schema("users").delete()

        // Drop enum types
        try await database.enum("notification_type").delete()
        try await database.enum("media_type").delete()
        try await database.enum("expense_category").delete()
        try await database.enum("transaction_type").delete()
        try await database.enum("reaction_type").delete()
        try await database.enum("post_type").delete()
        try await database.enum("event_category").delete()
        try await database.enum("rsvp_status").delete()
        try await database.enum("subscription_status").delete()
        try await database.enum("member_role").delete()
    }
}
