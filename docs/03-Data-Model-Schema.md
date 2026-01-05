# OrbitCove - Data Model & Schema Design

**Version**: 1.0 Draft
**Last Updated**: January 2026
**Status**: Review

---

## Table of Contents

1. [Overview](#overview)
2. [Entity Relationship Diagram](#entity-relationship-diagram)
3. [Core Entities](#core-entities)
4. [Multi-Tenancy Strategy](#multi-tenancy-strategy)
5. [Permission & Role System](#permission--role-system)
6. [Database Schema (PostgreSQL)](#database-schema-postgresql)
7. [Indexes & Performance](#indexes--performance)
8. [Data Lifecycle](#data-lifecycle)
9. [Privacy & Encryption Considerations](#privacy--encryption-considerations)
10. [iOS Local Schema (SwiftData)](#ios-local-schema-swiftdata)

---

## Overview

### Design Principles

1. **Community Isolation**: All user content belongs to a community; no data exists outside that context
2. **Soft Deletes**: User-facing deletions are soft deletes; hard deletes only via admin/retention policies
3. **Audit Trail**: Critical actions are logged for accountability
4. **Denormalization for Performance**: Strategic denormalization for read-heavy paths (e.g., member counts)
5. **E2E-Ready**: Schema supports future E2E encryption (content stored as encrypted blobs)

### Naming Conventions

- Tables: `snake_case`, plural (e.g., `users`, `communities`)
- Columns: `snake_case` (e.g., `created_at`, `community_id`)
- Primary keys: `id` (UUID)
- Foreign keys: `{table_singular}_id` (e.g., `user_id`, `community_id`)
- Timestamps: `created_at`, `updated_at`, `deleted_at`
- Boolean flags: `is_` prefix (e.g., `is_admin`, `is_pinned`)

---

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           ORBITCOVE DATA MODEL                                   │
└─────────────────────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │    users     │
    │──────────────│
    │ id (PK)      │
    │ apple_id     │
    │ email        │
    │ display_name │
    │ avatar_url   │
    └──────┬───────┘
           │
           │ 1:N
           ▼
    ┌──────────────┐         ┌──────────────┐
    │family_members│         │  communities │
    │──────────────│         │──────────────│
    │ id (PK)      │         │ id (PK)      │
    │ user_id (FK) │         │ name         │
    │ name         │         │ icon_url     │
    │ avatar_url   │         │ created_by   │
    └──────────────┘         └──────┬───────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
                    ▼               ▼               ▼
            ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
            │   members    │ │    events    │ │    posts     │
            │──────────────│ │──────────────│ │──────────────│
            │ id (PK)      │ │ id (PK)      │ │ id (PK)      │
            │ community_id │ │ community_id │ │ community_id │
            │ user_id (FK) │ │ title        │ │ author_id    │
            │ role         │ │ starts_at    │ │ content      │
            │ joined_at    │ │ location     │ │ type         │
            └──────────────┘ └──────┬───────┘ └──────┬───────┘
                                    │               │
                                    ▼               ▼
                            ┌──────────────┐ ┌──────────────┐
                            │    rsvps     │ │  reactions   │
                            │──────────────│ │──────────────│
                            │ event_id     │ │ post_id      │
                            │ user_id      │ │ user_id      │
                            │ status       │ │ type         │
                            └──────────────┘ └──────────────┘
                                                    │
                                                    │
                            ┌──────────────┐ ┌──────────────┐
                            │   comments   │ │ transactions │
                            │──────────────│ │──────────────│
                            │ id (PK)      │ │ id (PK)      │
                            │ post_id      │ │ community_id │
                            │ author_id    │ │ paid_by      │
                            │ content      │ │ amount       │
                            └──────────────┘ └──────┬───────┘
                                                    │
                                                    ▼
                                            ┌──────────────┐
                                            │   splits     │
                                            │──────────────│
                                            │ transaction_ │
                                            │ user_id      │
                                            │ amount       │
                                            │ is_settled   │
                                            └──────────────┘
```

---

## Core Entities

### Users

The authenticated user account.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `apple_id` | String | Apple Sign-In identifier (unique) |
| `email` | String | User's email (from Apple, may be relay) |
| `display_name` | String | User-chosen display name |
| `avatar_url` | String? | Profile photo URL |
| `created_at` | Timestamp | Account creation time |
| `updated_at` | Timestamp | Last profile update |
| `deleted_at` | Timestamp? | Soft delete timestamp |

**Notes**:
- `apple_id` is the stable identifier from Sign in with Apple
- Email may be Apple's relay email; don't depend on it for identity

### Family Members

Parent-managed profiles for children or dependents (no separate login).

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `user_id` | UUID | Parent user who manages this profile |
| `name` | String | Display name (e.g., "Tommy") |
| `avatar_url` | String? | Optional photo |
| `created_at` | Timestamp | Creation time |

**Notes**:
- Family members appear in RSVPs, attendance, etc.
- They cannot log in or receive notifications directly
- All actions flow through the parent's account

### Communities

A private group space (family, team, club).

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `name` | String | Community name |
| `description` | String? | Optional description |
| `icon_url` | String? | Community icon/photo |
| `created_by` | UUID | User who created the community |
| `member_count` | Integer | Denormalized count (updated via trigger) |
| `subscription_status` | Enum | `free`, `active`, `past_due`, `canceled` |
| `subscription_expires_at` | Timestamp? | When paid subscription ends |
| `settings` | JSONB | Community-level settings |
| `created_at` | Timestamp | Creation time |
| `updated_at` | Timestamp | Last update |
| `deleted_at` | Timestamp? | Soft delete |

**Settings JSONB Structure**:
```json
{
  "allowMemberEvents": true,
  "allowMemberPosts": true,
  "defaultReminderHours": 24,
  "timezone": "America/New_York"
}
```

### Members

Junction table for user-community membership.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `community_id` | UUID | FK to communities |
| `user_id` | UUID | FK to users |
| `role` | Enum | `admin`, `member` |
| `nickname` | String? | Optional community-specific nickname |
| `notification_prefs` | JSONB | Per-community notification settings |
| `joined_at` | Timestamp | When user joined |
| `invited_by` | UUID? | User who invited them |
| `left_at` | Timestamp? | When user left (soft leave) |

**Unique Constraint**: `(community_id, user_id)` - user can only be member once per community

### Invites

Pending invitations to join a community.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `community_id` | UUID | FK to communities |
| `code` | String | 6-character invite code |
| `created_by` | UUID | Admin who created invite |
| `uses_remaining` | Integer? | Null = unlimited |
| `expires_at` | Timestamp? | Optional expiration |
| `created_at` | Timestamp | Creation time |

**Unique Constraint**: `code` must be globally unique

---

### Events (Calendar)

Calendar events within a community.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `community_id` | UUID | FK to communities |
| `created_by` | UUID | User who created event |
| `title` | String | Event title |
| `description` | String? | Optional description |
| `starts_at` | Timestamp | Event start time (UTC) |
| `ends_at` | Timestamp? | Optional end time |
| `all_day` | Boolean | Is this an all-day event? |
| `location_name` | String? | Human-readable location |
| `location_lat` | Decimal? | Latitude |
| `location_lng` | Decimal? | Longitude |
| `location_address` | String? | Full address |
| `category` | Enum | `practice`, `game`, `meeting`, `social`, `other` |
| `recurrence_rule` | String? | iCal RRULE format |
| `recurrence_parent_id` | UUID? | For recurring instances, links to parent |
| `attachments` | JSONB | Array of attachment URLs |
| `rsvp_deadline` | Timestamp? | Optional RSVP cutoff |
| `created_at` | Timestamp | Creation time |
| `updated_at` | Timestamp | Last update |
| `deleted_at` | Timestamp? | Soft delete |

**Recurrence Handling**:
- Parent event has `recurrence_rule` (e.g., `FREQ=WEEKLY;BYDAY=TU`)
- Individual instances are created as needed with `recurrence_parent_id`
- Modifying one instance breaks it from the series

### RSVPs

User responses to events.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `event_id` | UUID | FK to events |
| `user_id` | UUID | FK to users |
| `family_member_id` | UUID? | If RSVP is for a managed family member |
| `status` | Enum | `yes`, `no`, `maybe` |
| `plus_ones` | Integer | Number of additional guests (default 0) |
| `note` | String? | Optional note ("Arriving 10 min late") |
| `responded_at` | Timestamp | When response was recorded |
| `updated_at` | Timestamp | Last update |

**Unique Constraint**: `(event_id, user_id, family_member_id)` - one RSVP per person per event

---

### Posts (Feed)

Social feed posts within a community.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `community_id` | UUID | FK to communities |
| `author_id` | UUID | FK to users |
| `type` | Enum | `text`, `photo`, `announcement`, `poll`, `event_share` |
| `content` | Text | Post text content |
| `media_urls` | JSONB | Array of media URLs |
| `is_pinned` | Boolean | Is post pinned to top? |
| `is_announcement` | Boolean | Show as announcement banner? |
| `linked_event_id` | UUID? | If type=event_share, links to event |
| `poll_data` | JSONB? | Poll options and settings |
| `editable_until` | Timestamp | 24 hours after creation |
| `reaction_counts` | JSONB | Denormalized: `{"like": 5, "love": 2}` |
| `comment_count` | Integer | Denormalized comment count |
| `created_at` | Timestamp | Creation time |
| `updated_at` | Timestamp | Last update |
| `deleted_at` | Timestamp? | Soft delete |

**Poll Data Structure**:
```json
{
  "question": "What day works best?",
  "options": ["Saturday", "Sunday"],
  "allowMultiple": false,
  "closesAt": "2026-01-10T00:00:00Z"
}
```

### Reactions

User reactions to posts.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `post_id` | UUID | FK to posts |
| `user_id` | UUID | FK to users |
| `type` | Enum | `like`, `love`, `laugh`, `celebrate` |
| `created_at` | Timestamp | When reaction was added |

**Unique Constraint**: `(post_id, user_id)` - one reaction per user per post (can change type)

### Comments

Comments on posts.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `post_id` | UUID | FK to posts |
| `author_id` | UUID | FK to users |
| `parent_id` | UUID? | For threaded replies |
| `content` | Text | Comment text |
| `created_at` | Timestamp | Creation time |
| `updated_at` | Timestamp | Last update |
| `deleted_at` | Timestamp? | Soft delete |

### Poll Votes

Votes on poll posts.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `post_id` | UUID | FK to posts (must be poll type) |
| `user_id` | UUID | FK to users |
| `option_index` | Integer | Index of selected option |
| `created_at` | Timestamp | When vote was cast |

**Unique Constraint**: `(post_id, user_id, option_index)` - depends on `allowMultiple` setting

---

### Transactions (Finances)

Financial transactions within a community.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `community_id` | UUID | FK to communities |
| `created_by` | UUID | User who logged the transaction |
| `type` | Enum | `expense`, `settlement`, `dues` |
| `description` | String | What the expense was for |
| `total_amount` | Decimal(10,2) | Total amount in cents (stored as integer) |
| `currency` | String | ISO currency code (default: USD) |
| `paid_by` | UUID | User who paid |
| `category` | Enum | `equipment`, `food`, `travel`, `dues`, `other` |
| `receipt_url` | String? | Receipt image URL |
| `linked_event_id` | UUID? | Optional link to related event |
| `transaction_date` | Date | When expense occurred |
| `created_at` | Timestamp | When logged in app |
| `updated_at` | Timestamp | Last update |
| `deleted_at` | Timestamp? | Soft delete |

**Note**: Amounts stored as integers (cents) to avoid floating point issues.

### Splits

How a transaction is split among members.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `transaction_id` | UUID | FK to transactions |
| `user_id` | UUID | FK to users (who owes) |
| `amount` | Decimal(10,2) | Amount owed (in cents) |
| `is_settled` | Boolean | Has this portion been paid? |
| `settled_at` | Timestamp? | When marked as settled |
| `settled_via` | String? | How settled (venmo, cash, etc.) |

**Constraint**: Sum of split amounts should equal transaction total

### Balances (Materialized View)

Aggregated balance per user per community.

| Field | Type | Description |
|-------|------|-------------|
| `community_id` | UUID | Community |
| `user_id` | UUID | User |
| `balance` | Decimal | Positive = owed money, Negative = owes money |
| `last_updated` | Timestamp | When recalculated |

**Implementation**: Materialized view refreshed on transaction changes, or computed on-demand.

### Dues

Recurring dues setup for a community.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `community_id` | UUID | FK to communities |
| `name` | String | e.g., "2026 Season Dues" |
| `amount` | Decimal(10,2) | Amount per member |
| `due_date` | Date | When payment is due |
| `is_active` | Boolean | Currently collecting? |
| `created_by` | UUID | Admin who set up dues |
| `created_at` | Timestamp | Creation time |

### Dues Payments

Track who has paid dues.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `dues_id` | UUID | FK to dues |
| `user_id` | UUID | FK to users |
| `amount_paid` | Decimal(10,2) | Amount paid (for partial payments) |
| `paid_at` | Timestamp | When payment recorded |
| `recorded_by` | UUID | Who marked it paid |
| `payment_method` | String? | How they paid |
| `notes` | String? | Any notes |

---

### Media

Uploaded media files.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `community_id` | UUID | FK to communities |
| `uploaded_by` | UUID | FK to users |
| `type` | Enum | `image`, `video`, `document` |
| `filename` | String | Original filename |
| `mime_type` | String | MIME type |
| `size_bytes` | Integer | File size |
| `storage_path` | String | Azure Blob path |
| `thumbnail_path` | String? | Thumbnail for images/videos |
| `width` | Integer? | For images/videos |
| `height` | Integer? | For images/videos |
| `created_at` | Timestamp | Upload time |

---

### Notifications

Notification records (for history/unread tracking).

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `user_id` | UUID | Recipient |
| `community_id` | UUID? | Related community |
| `type` | Enum | `event_reminder`, `new_post`, `mention`, `rsvp_request`, `payment_request` |
| `title` | String | Notification title |
| `body` | String | Notification body |
| `data` | JSONB | Deep link data |
| `read_at` | Timestamp? | When read |
| `created_at` | Timestamp | When created |

---

### Audit Log

Track important actions for accountability.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `community_id` | UUID? | Related community |
| `user_id` | UUID | Who performed action |
| `action` | String | Action type (e.g., `member.removed`) |
| `target_type` | String | Entity type affected |
| `target_id` | UUID | Entity ID affected |
| `metadata` | JSONB | Additional context |
| `ip_address` | String? | Request IP |
| `created_at` | Timestamp | When action occurred |

**Logged Actions**:
- Member added/removed
- Role changes
- Community settings changed
- Subscription changes
- Account deletion

---

## Multi-Tenancy Strategy

### Approach: Shared Database, Schema-Level Isolation

All communities share the same database, but data is isolated by `community_id` on every query.

```
┌─────────────────────────────────────────────────────────────────┐
│                    MULTI-TENANCY STRATEGY                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                  PostgreSQL Database                     │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐        │    │
│  │  │ Community A │ │ Community B │ │ Community C │        │    │
│  │  │ (family)    │ │ (team)      │ │ (club)      │        │    │
│  │  │             │ │             │ │             │        │    │
│  │  │ Events      │ │ Events      │ │ Events      │        │    │
│  │  │ Posts       │ │ Posts       │ │ Posts       │        │    │
│  │  │ Txns        │ │ Txns        │ │ Txns        │        │    │
│  │  └─────────────┘ └─────────────┘ └─────────────┘        │    │
│  │                                                          │    │
│  │  Row-Level Security (RLS) ensures queries only return    │    │
│  │  data for communities the user is a member of            │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Enforcement Layers

1. **Application Layer**: All queries include `WHERE community_id = ?`
2. **Row-Level Security (RLS)**: PostgreSQL RLS policies as second defense
3. **API Layer**: Validate user is member of community before any operation

### RLS Policy Example

```sql
-- Enable RLS on events table
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see events in their communities
CREATE POLICY events_community_isolation ON events
  FOR ALL
  USING (
    community_id IN (
      SELECT community_id FROM members
      WHERE user_id = current_setting('app.current_user_id')::uuid
      AND left_at IS NULL
    )
  );
```

---

## Permission & Role System

### Role Definitions

| Role | Description |
|------|-------------|
| `admin` | Full control over community. Can manage members, settings, delete content. |
| `member` | Standard member. Can view all, create content (based on settings). |

### Permission Matrix

| Action | Admin | Member | Notes |
|--------|-------|--------|-------|
| View community content | ✓ | ✓ | |
| Create events | ✓ | Configurable | `settings.allowMemberEvents` |
| Edit/delete own events | ✓ | ✓ | |
| Edit/delete any event | ✓ | ✗ | |
| Create posts | ✓ | Configurable | `settings.allowMemberPosts` |
| Create announcements | ✓ | ✗ | |
| Pin posts | ✓ | ✗ | |
| Edit/delete own posts | ✓ | ✓ | Within 24 hours |
| Edit/delete any post | ✓ | ✗ | |
| Add expenses | ✓ | ✓ | |
| Set up dues | ✓ | ✗ | |
| Mark dues as paid | ✓ | ✗ | |
| Invite members | ✓ | ✗ | |
| Remove members | ✓ | ✗ | |
| Change member roles | ✓ | ✗ | |
| Edit community settings | ✓ | ✗ | |
| Delete community | ✓ | ✗ | Only creator initially |
| Manage subscription | ✓ | ✗ | Only creator initially |

### Permission Check Pseudocode

```swift
func canPerformAction(_ action: Action, user: User, community: Community) -> Bool {
    guard let membership = user.membership(in: community) else {
        return false // Not a member
    }

    switch action {
    case .createEvent:
        return membership.isAdmin || community.settings.allowMemberEvents
    case .deleteEvent(let event):
        return membership.isAdmin || event.createdBy == user.id
    case .createAnnouncement:
        return membership.isAdmin
    // ... etc
    }
}
```

---

## Database Schema (PostgreSQL)

### Full Schema DDL

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enum types
CREATE TYPE member_role AS ENUM ('admin', 'member');
CREATE TYPE subscription_status AS ENUM ('free', 'active', 'past_due', 'canceled');
CREATE TYPE rsvp_status AS ENUM ('yes', 'no', 'maybe');
CREATE TYPE event_category AS ENUM ('practice', 'game', 'meeting', 'social', 'other');
CREATE TYPE post_type AS ENUM ('text', 'photo', 'announcement', 'poll', 'event_share');
CREATE TYPE reaction_type AS ENUM ('like', 'love', 'laugh', 'celebrate');
CREATE TYPE transaction_type AS ENUM ('expense', 'settlement', 'dues');
CREATE TYPE expense_category AS ENUM ('equipment', 'food', 'travel', 'dues', 'other');
CREATE TYPE media_type AS ENUM ('image', 'video', 'document');
CREATE TYPE notification_type AS ENUM ('event_reminder', 'new_post', 'mention', 'rsvp_request', 'payment_request');

-- ============================================
-- USERS
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    apple_id VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    avatar_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_users_apple_id ON users(apple_id);
CREATE INDEX idx_users_email ON users(email);

-- ============================================
-- FAMILY MEMBERS
-- ============================================
CREATE TABLE family_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    avatar_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_family_members_user ON family_members(user_id);

-- ============================================
-- COMMUNITIES
-- ============================================
CREATE TABLE communities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url VARCHAR(500),
    created_by UUID NOT NULL REFERENCES users(id),
    member_count INTEGER DEFAULT 1,
    subscription_status subscription_status DEFAULT 'free',
    subscription_expires_at TIMESTAMP WITH TIME ZONE,
    stripe_customer_id VARCHAR(255),
    stripe_subscription_id VARCHAR(255),
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_communities_created_by ON communities(created_by);

-- ============================================
-- MEMBERS
-- ============================================
CREATE TABLE members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role member_role DEFAULT 'member',
    nickname VARCHAR(100),
    notification_prefs JSONB DEFAULT '{}',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    invited_by UUID REFERENCES users(id),
    left_at TIMESTAMP WITH TIME ZONE,

    UNIQUE(community_id, user_id)
);

CREATE INDEX idx_members_community ON members(community_id) WHERE left_at IS NULL;
CREATE INDEX idx_members_user ON members(user_id) WHERE left_at IS NULL;

-- ============================================
-- INVITES
-- ============================================
CREATE TABLE invites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    code VARCHAR(10) UNIQUE NOT NULL,
    created_by UUID NOT NULL REFERENCES users(id),
    uses_remaining INTEGER,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_invites_code ON invites(code);

-- ============================================
-- EVENTS
-- ============================================
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES users(id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    starts_at TIMESTAMP WITH TIME ZONE NOT NULL,
    ends_at TIMESTAMP WITH TIME ZONE,
    all_day BOOLEAN DEFAULT FALSE,
    location_name VARCHAR(200),
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    location_address TEXT,
    category event_category DEFAULT 'other',
    recurrence_rule VARCHAR(500),
    recurrence_parent_id UUID REFERENCES events(id),
    attachments JSONB DEFAULT '[]',
    rsvp_deadline TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_events_community ON events(community_id, starts_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_events_recurrence ON events(recurrence_parent_id);

-- ============================================
-- RSVPS
-- ============================================
CREATE TABLE rsvps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    family_member_id UUID REFERENCES family_members(id) ON DELETE CASCADE,
    status rsvp_status NOT NULL,
    plus_ones INTEGER DEFAULT 0,
    note VARCHAR(500),
    responded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(event_id, user_id, family_member_id)
);

CREATE INDEX idx_rsvps_event ON rsvps(event_id);

-- ============================================
-- POSTS
-- ============================================
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES users(id),
    type post_type DEFAULT 'text',
    content TEXT,
    media_urls JSONB DEFAULT '[]',
    is_pinned BOOLEAN DEFAULT FALSE,
    is_announcement BOOLEAN DEFAULT FALSE,
    linked_event_id UUID REFERENCES events(id),
    poll_data JSONB,
    editable_until TIMESTAMP WITH TIME ZONE,
    reaction_counts JSONB DEFAULT '{}',
    comment_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_posts_community ON posts(community_id, created_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_posts_pinned ON posts(community_id) WHERE is_pinned = TRUE AND deleted_at IS NULL;

-- ============================================
-- REACTIONS
-- ============================================
CREATE TABLE reactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type reaction_type NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(post_id, user_id)
);

CREATE INDEX idx_reactions_post ON reactions(post_id);

-- ============================================
-- COMMENTS
-- ============================================
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES users(id),
    parent_id UUID REFERENCES comments(id),
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_comments_post ON comments(post_id, created_at) WHERE deleted_at IS NULL;

-- ============================================
-- POLL VOTES
-- ============================================
CREATE TABLE poll_votes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    option_index INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_poll_votes_post ON poll_votes(post_id);

-- ============================================
-- TRANSACTIONS
-- ============================================
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES users(id),
    type transaction_type NOT NULL,
    description VARCHAR(500) NOT NULL,
    total_amount INTEGER NOT NULL, -- cents
    currency VARCHAR(3) DEFAULT 'USD',
    paid_by UUID NOT NULL REFERENCES users(id),
    category expense_category DEFAULT 'other',
    receipt_url VARCHAR(500),
    linked_event_id UUID REFERENCES events(id),
    transaction_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_transactions_community ON transactions(community_id, created_at DESC) WHERE deleted_at IS NULL;

-- ============================================
-- SPLITS
-- ============================================
CREATE TABLE splits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id UUID NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    amount INTEGER NOT NULL, -- cents
    is_settled BOOLEAN DEFAULT FALSE,
    settled_at TIMESTAMP WITH TIME ZONE,
    settled_via VARCHAR(50)
);

CREATE INDEX idx_splits_transaction ON splits(transaction_id);
CREATE INDEX idx_splits_user_unsettled ON splits(user_id) WHERE is_settled = FALSE;

-- ============================================
-- DUES
-- ============================================
CREATE TABLE dues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    amount INTEGER NOT NULL, -- cents
    due_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_dues_community ON dues(community_id) WHERE is_active = TRUE;

-- ============================================
-- DUES PAYMENTS
-- ============================================
CREATE TABLE dues_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dues_id UUID NOT NULL REFERENCES dues(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    amount_paid INTEGER NOT NULL, -- cents
    paid_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    recorded_by UUID NOT NULL REFERENCES users(id),
    payment_method VARCHAR(50),
    notes TEXT
);

CREATE INDEX idx_dues_payments_dues ON dues_payments(dues_id);

-- ============================================
-- MEDIA
-- ============================================
CREATE TABLE media (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES users(id),
    type media_type NOT NULL,
    filename VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    size_bytes INTEGER NOT NULL,
    storage_path VARCHAR(500) NOT NULL,
    thumbnail_path VARCHAR(500),
    width INTEGER,
    height INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_media_community ON media(community_id, created_at DESC);

-- ============================================
-- NOTIFICATIONS
-- ============================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    community_id UUID REFERENCES communities(id) ON DELETE CASCADE,
    type notification_type NOT NULL,
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_unread ON notifications(user_id) WHERE read_at IS NULL;

-- ============================================
-- AUDIT LOG
-- ============================================
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    community_id UUID REFERENCES communities(id) ON DELETE SET NULL,
    user_id UUID NOT NULL REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    target_type VARCHAR(50),
    target_id UUID,
    metadata JSONB DEFAULT '{}',
    ip_address INET,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_audit_community ON audit_log(community_id, created_at DESC);

-- ============================================
-- REFRESH TOKENS
-- ============================================
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(64) NOT NULL UNIQUE,
    device_name VARCHAR(100),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    revoked_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id) WHERE revoked_at IS NULL;

-- ============================================
-- TRIGGERS
-- ============================================

-- Update member count on insert/delete
CREATE OR REPLACE FUNCTION update_member_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE communities SET member_count = member_count + 1, updated_at = NOW()
        WHERE id = NEW.community_id;
    ELSIF TG_OP = 'UPDATE' AND OLD.left_at IS NULL AND NEW.left_at IS NOT NULL THEN
        UPDATE communities SET member_count = member_count - 1, updated_at = NOW()
        WHERE id = NEW.community_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_member_count
AFTER INSERT OR UPDATE ON members
FOR EACH ROW EXECUTE FUNCTION update_member_count();

-- Update comment count on posts
CREATE OR REPLACE FUNCTION update_comment_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE posts SET comment_count = comment_count + 1 WHERE id = NEW.post_id;
    ELSIF TG_OP = 'UPDATE' AND OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
        UPDATE posts SET comment_count = comment_count - 1 WHERE id = NEW.post_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_comment_count
AFTER INSERT OR UPDATE ON comments
FOR EACH ROW EXECUTE FUNCTION update_comment_count();

-- Set editable_until on post creation
CREATE OR REPLACE FUNCTION set_post_editable_until()
RETURNS TRIGGER AS $$
BEGIN
    NEW.editable_until := NEW.created_at + INTERVAL '24 hours';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_post_editable
BEFORE INSERT ON posts
FOR EACH ROW EXECUTE FUNCTION set_post_editable_until();
```

---

## Indexes & Performance

### Query Patterns & Indexes

| Query Pattern | Index |
|---------------|-------|
| Get user's communities | `idx_members_user` |
| Get community members | `idx_members_community` |
| Get upcoming events | `idx_events_community` (includes starts_at) |
| Get recent posts | `idx_posts_community` (includes created_at DESC) |
| Get pinned posts | `idx_posts_pinned` |
| Get unsettled splits for user | `idx_splits_user_unsettled` |
| Get unread notifications | `idx_notifications_unread` |
| Lookup invite code | `idx_invites_code` |

### Pagination Strategy

Use cursor-based pagination for infinite scroll:

```sql
-- Get next page of posts
SELECT * FROM posts
WHERE community_id = $1
  AND deleted_at IS NULL
  AND (created_at, id) < ($last_created_at, $last_id)
ORDER BY created_at DESC, id DESC
LIMIT 20;
```

### Expensive Queries to Monitor

1. **Balance calculation**: May need materialized view for communities with many transactions
2. **Simplify debts algorithm**: Run async, cache results
3. **Full-text search on posts**: Consider PostgreSQL `tsvector` or external search

---

## Data Lifecycle

### Retention Policies

| Data Type | Retention | Notes |
|-----------|-----------|-------|
| Active user data | Indefinite | Until user deletes account |
| Deleted posts | 30 days | Then hard delete |
| Audit logs | 2 years | Compliance requirement |
| Notifications | 90 days | Then hard delete |
| Expired invites | 7 days | Then hard delete |
| Revoked tokens | 30 days | Then hard delete |

### Account Deletion Flow

1. User requests deletion
2. 7-day grace period (can cancel)
3. After grace period:
   - User record soft deleted
   - Personal data anonymized
   - Content remains but shows "[Deleted User]"
   - Remove from all community memberships
   - Purge from audit logs after retention period

### Community Deletion Flow

1. Admin requests deletion
2. Immediate soft delete (hidden from all members)
3. 30-day grace period (admin can restore)
4. After grace period: hard delete all community data

---

## Privacy & Encryption Considerations

### MVP (v1.0) - Server-Side Access

In v1.0, server can read all content. Privacy protections:

- Data encrypted at rest by Azure
- TLS 1.3 in transit
- Access logging for all data access
- Employee access requires audit trail
- No third-party data sharing

### v1.1 - E2E Encryption Migration

When adding E2E encryption:

1. **New content**: Encrypted client-side before upload
2. **Existing content**: Remains server-readable (grandfather clause) OR
3. **Migration option**: Client re-encrypts existing content on next access

**Schema changes for E2E**:

```sql
-- Add encrypted content columns
ALTER TABLE posts ADD COLUMN content_encrypted BYTEA;
ALTER TABLE posts ADD COLUMN encryption_version INTEGER DEFAULT 0;
-- 0 = plaintext, 1 = E2E v1

-- Community encryption keys (encrypted per-member)
CREATE TABLE community_keys (
    id UUID PRIMARY KEY,
    community_id UUID NOT NULL REFERENCES communities(id),
    user_id UUID NOT NULL REFERENCES users(id),
    encrypted_key BYTEA NOT NULL, -- Community key encrypted with user's public key
    key_version INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## iOS Local Schema (SwiftData)

### SwiftData Models

```swift
import SwiftData

@Model
final class LocalUser {
    @Attribute(.unique) var id: UUID
    var appleId: String
    var email: String
    var displayName: String
    var avatarUrl: String?

    @Relationship(deleteRule: .cascade)
    var familyMembers: [LocalFamilyMember]

    @Relationship
    var memberships: [LocalMembership]
}

@Model
final class LocalFamilyMember {
    @Attribute(.unique) var id: UUID
    var name: String
    var avatarUrl: String?

    var user: LocalUser?
}

@Model
final class LocalCommunity {
    @Attribute(.unique) var id: UUID
    var name: String
    var descriptionText: String?
    var iconUrl: String?
    var memberCount: Int
    var settings: CommunitySettings // Codable struct

    @Relationship(deleteRule: .cascade)
    var events: [LocalEvent]

    @Relationship(deleteRule: .cascade)
    var posts: [LocalPost]

    @Relationship(deleteRule: .cascade)
    var transactions: [LocalTransaction]

    var lastSyncedAt: Date?
}

@Model
final class LocalMembership {
    @Attribute(.unique) var id: UUID
    var role: MemberRole
    var joinedAt: Date

    var user: LocalUser?
    var community: LocalCommunity?
}

@Model
final class LocalEvent {
    @Attribute(.unique) var id: UUID
    var title: String
    var descriptionText: String?
    var startsAt: Date
    var endsAt: Date?
    var allDay: Bool
    var locationName: String?
    var locationLat: Double?
    var locationLng: Double?
    var category: EventCategory

    @Relationship(deleteRule: .cascade)
    var rsvps: [LocalRSVP]

    var community: LocalCommunity?

    // Sync metadata
    var localCreatedAt: Date?
    var syncStatus: SyncStatus // .synced, .pendingUpload, .pendingDelete
}

@Model
final class LocalRSVP {
    @Attribute(.unique) var id: UUID
    var status: RSVPStatus
    var plusOnes: Int
    var note: String?

    var event: LocalEvent?
    var userId: UUID
    var familyMemberId: UUID?
}

@Model
final class LocalPost {
    @Attribute(.unique) var id: UUID
    var type: PostType
    var content: String?
    var mediaUrls: [String]
    var isPinned: Bool
    var isAnnouncement: Bool
    var reactionCounts: [String: Int]
    var commentCount: Int
    var createdAt: Date
    var authorId: UUID
    var authorName: String // Denormalized for offline display

    @Relationship(deleteRule: .cascade)
    var comments: [LocalComment]

    var community: LocalCommunity?
    var syncStatus: SyncStatus
}

@Model
final class LocalComment {
    @Attribute(.unique) var id: UUID
    var content: String
    var authorId: UUID
    var authorName: String
    var createdAt: Date

    var post: LocalPost?
    var syncStatus: SyncStatus
}

@Model
final class LocalTransaction {
    @Attribute(.unique) var id: UUID
    var type: TransactionType
    var descriptionText: String
    var totalAmount: Int // cents
    var paidById: UUID
    var paidByName: String
    var category: ExpenseCategory
    var transactionDate: Date

    @Relationship(deleteRule: .cascade)
    var splits: [LocalSplit]

    var community: LocalCommunity?
    var syncStatus: SyncStatus
}

@Model
final class LocalSplit {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var userName: String
    var amount: Int
    var isSettled: Bool

    var transaction: LocalTransaction?
}

// Pending operations queue
@Model
final class PendingOperation {
    @Attribute(.unique) var id: UUID
    var operationType: OperationType
    var entityType: String
    var entityId: UUID
    var payload: Data // JSON-encoded operation
    var createdAt: Date
    var retryCount: Int
    var lastError: String?
}

// Enums
enum SyncStatus: String, Codable {
    case synced
    case pendingUpload
    case pendingUpdate
    case pendingDelete
    case conflicted
}

enum OperationType: String, Codable {
    case create
    case update
    case delete
}
```

### Sync Strategy

```swift
class SyncService {
    // Incremental sync
    func sync(community: LocalCommunity) async throws {
        let since = community.lastSyncedAt ?? .distantPast

        let changes = try await api.getCommunitySync(
            communityId: community.id,
            since: since
        )

        // Apply server changes
        try await applyChanges(changes, to: community)

        // Upload pending local changes
        try await uploadPendingOperations(for: community)

        community.lastSyncedAt = Date()
    }

    // Conflict resolution
    func resolveConflict(_ local: LocalEvent, _ server: EventDTO) -> LocalEvent {
        // Last-write-wins based on updatedAt
        if server.updatedAt > local.updatedAt {
            return LocalEvent(from: server)
        }
        return local
    }
}
```

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 2026 | Claude | Initial draft |

---

*Next document: UX Flows*
