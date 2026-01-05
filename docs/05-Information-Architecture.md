# OrbitCove - Information Architecture

**Version**: 1.0 Draft
**Last Updated**: January 2026
**Status**: Review

---

## Table of Contents

1. [Overview](#overview)
2. [Content Hierarchy](#content-hierarchy)
3. [App Structure Map](#app-structure-map)
4. [Pillar Integration Model](#pillar-integration-model)
5. [Community vs Personal Boundaries](#community-vs-personal-boundaries)
6. [Cross-Cutting Concepts](#cross-cutting-concepts)
7. [Search & Discovery](#search--discovery)
8. [Deep Linking Structure](#deep-linking-structure)
9. [Content Lifecycle](#content-lifecycle)

---

## Overview

### Core Mental Model

OrbitCove is organized around **Communities** as the primary container. All content exists within a community context—there is no "global" feed or content that spans communities.

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER ACCOUNT                              │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                     Communities                              ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          ││
│  │  │   Family    │  │    Team     │  │    Club     │          ││
│  │  │             │  │             │  │             │          ││
│  │  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │          ││
│  │  │ │Calendar │ │  │ │Calendar │ │  │ │Calendar │ │          ││
│  │  │ ├─────────┤ │  │ ├─────────┤ │  │ ├─────────┤ │          ││
│  │  │ │  Feed   │ │  │ │  Feed   │ │  │ │  Feed   │ │          ││
│  │  │ ├─────────┤ │  │ ├─────────┤ │  │ ├─────────┤ │          ││
│  │  │ │Finances │ │  │ │Finances │ │  │ │Finances │ │          ││
│  │  │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │          ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘          ││
│  └─────────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                   Profile & Settings                         ││
│  │  (Account-level, spans all communities)                      ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Community Isolation**: Content in one community is never visible in another
2. **Consistent Structure**: Every community has the same three pillars (Calendar, Feed, Finances)
3. **Single Active Context**: User is always "in" one community at a time
4. **Account Spans All**: Profile, settings, and notifications are account-level

---

## Content Hierarchy

### Level 1: Account (User)

The authenticated user. Owns:
- Profile information (name, avatar)
- Family members (managed profiles)
- Notification preferences
- App settings
- List of community memberships

### Level 2: Community

A private group space. Contains:
- Community metadata (name, icon, settings)
- Member list with roles
- All content pillars (Calendar, Feed, Finances)
- Invite codes

### Level 3: Pillars

Each community has three pillars (MVP):

| Pillar | Contains |
|--------|----------|
| **Calendar** | Events, RSVPs |
| **Feed** | Posts, Comments, Reactions, Polls |
| **Finances** | Transactions, Splits, Dues |

### Level 4: Content Items

Individual pieces of content within pillars:

```
Community
├── Calendar
│   ├── Event
│   │   ├── RSVPs
│   │   └── Attachments
│   └── Event
│       └── ...
├── Feed
│   ├── Post
│   │   ├── Reactions
│   │   ├── Comments
│   │   │   └── Replies
│   │   └── Poll Votes (if poll)
│   └── Post
│       └── ...
└── Finances
    ├── Transaction
    │   └── Splits
    ├── Transaction
    │   └── ...
    └── Dues
        └── Payments
```

---

## App Structure Map

### Complete Screen Hierarchy

```
OrbitCove App
│
├── 🚀 Onboarding (unauthenticated)
│   ├── Welcome Screen
│   ├── Sign In with Apple
│   ├── Create Community
│   │   └── Invite Members
│   └── Join Community
│
├── 🏠 Main App (authenticated)
│   │
│   ├── Community Switcher (overlay)
│   │   ├── Community List
│   │   ├── Create New Community
│   │   └── Join with Code
│   │
│   ├── 📅 Calendar Tab
│   │   ├── Calendar View (Month/List toggle)
│   │   ├── Event Detail
│   │   │   ├── RSVP Action
│   │   │   ├── Family RSVP Sheet
│   │   │   ├── Add to Calendar
│   │   │   ├── Get Directions
│   │   │   └── Edit Event (creator/admin)
│   │   ├── Create Event Sheet
│   │   │   ├── Recurrence Picker
│   │   │   ├── Location Picker
│   │   │   ├── Category Picker
│   │   │   └── Attachment Picker
│   │   └── Edit Event Sheet
│   │
│   ├── 📰 Feed Tab
│   │   ├── Feed List
│   │   │   ├── Pinned Posts Section
│   │   │   └── Chronological Posts
│   │   ├── Post Detail
│   │   │   ├── Comments List
│   │   │   ├── Add Comment
│   │   │   └── Reaction Picker
│   │   ├── Create Post Sheet
│   │   │   ├── Photo Picker
│   │   │   ├── Poll Creator
│   │   │   └── Announcement Toggle (admin)
│   │   └── Edit Post Sheet
│   │
│   ├── 💰 Finances Tab
│   │   ├── Finances Overview
│   │   │   ├── Balance Summary
│   │   │   ├── Dues Status (if active)
│   │   │   └── Recent Transactions
│   │   ├── Transaction Detail
│   │   │   └── Split Breakdown
│   │   ├── Add Expense Sheet
│   │   │   ├── Member Selector
│   │   │   ├── Custom Split Editor
│   │   │   └── Receipt Camera
│   │   ├── Settle Up Screen
│   │   │   └── Venmo Deep Link
│   │   ├── All Transactions List
│   │   ├── Dues Detail (admin)
│   │   │   ├── Payment Tracker
│   │   │   └── Send Reminder
│   │   └── Set Up Dues Sheet (admin)
│   │
│   └── 👤 Profile Tab
│       ├── Profile Overview
│       │   ├── User Info
│       │   ├── Family Members List
│       │   └── Communities List
│       ├── Edit Profile
│       ├── Family Members
│       │   ├── Add Family Member
│       │   └── Edit Family Member
│       ├── Community Settings (per community)
│       │   ├── Community Info
│       │   ├── Members List
│       │   │   ├── Member Detail
│       │   │   ├── Change Role
│       │   │   └── Remove Member
│       │   ├── Invite Members
│       │   ├── Notification Settings
│       │   ├── Community Preferences
│       │   └── Leave/Delete Community
│       ├── App Settings
│       │   ├── Notifications (global)
│       │   ├── Appearance
│       │   ├── Privacy
│       │   └── About
│       ├── Notification Center
│       └── Account
│           ├── Subscription Status
│           ├── Export Data
│           └── Delete Account
│
└── 🔔 Notifications (overlay from any screen)
    └── Notification List
```

### Navigation Patterns

| Pattern | Usage |
|---------|-------|
| **Tab Bar** | Primary navigation between pillars + profile |
| **Push Navigation** | Drilling into detail screens |
| **Bottom Sheet** | Creation flows, quick actions, pickers |
| **Modal** | Full-screen takeovers (onboarding, settings) |
| **Overlay** | Community switcher, notification center |

### Screen Types

| Type | Characteristics | Examples |
|------|-----------------|----------|
| **List** | Scrollable content, pull-to-refresh | Feed, Calendar, Transactions |
| **Detail** | Single item focus, actions | Event Detail, Post Detail |
| **Form** | Input fields, save action | Create Event, Add Expense |
| **Settings** | Grouped options, toggles | Community Settings, Notifications |
| **Empty State** | Illustration, CTA | No posts, no events |

---

## Pillar Integration Model

### How Pillars Connect

The three pillars are not isolated silos—they reference and enhance each other.

```
┌─────────────────────────────────────────────────────────────────┐
│                     PILLAR INTEGRATION                           │
└─────────────────────────────────────────────────────────────────┘

                        ┌─────────────┐
                        │   CALENDAR  │
                        │             │
                        │   Events    │
                        └──────┬──────┘
                               │
            ┌──────────────────┼──────────────────┐
            │                  │                  │
            ▼                  ▼                  ▼
     Auto-posts to        Event can be      Expense can
     Feed when            linked to an      be linked to
     created              expense           an event
            │                  │                  │
            │                  │                  │
            ▼                  ▼                  ▼
     ┌─────────────┐                      ┌─────────────┐
     │    FEED     │◄────────────────────►│  FINANCES   │
     │             │   Poll results can   │             │
     │   Posts     │   trigger expense    │ Transactions│
     └─────────────┘   (future feature)   └─────────────┘
```

### Integration Points

#### Calendar → Feed

| Trigger | Action |
|---------|--------|
| Event created | Auto-post: "New event: {title}" with RSVP button |
| Event updated (time/location) | Auto-post: "Event updated: {title}" |
| Event canceled | Auto-post: "Event canceled: {title}" |
| RSVP deadline approaching | (Future) Auto-post reminder |

#### Calendar → Finances

| Integration | Description |
|-------------|-------------|
| Link expense to event | "Snacks for Practice (Jan 25)" |
| Event-based expense | Create expense directly from event detail |
| (Future) RSVP-based split | Only split among "Going" members |

#### Feed → Calendar

| Integration | Description |
|-------------|-------------|
| Event share post | Tapping opens event detail |
| Quick RSVP from feed | RSVP buttons in event share post |

#### Feed → Finances

| Integration | Description |
|-------------|-------------|
| (Future) Poll → Expense | "Team voted for pizza. Creating expense..." |
| Dues announcement | Auto-post when dues are set up |
| Payment reminder | Auto-post for overdue payments |

#### Finances → Feed

| Trigger | Action |
|---------|--------|
| Dues created | Auto-post: "New dues: {name} - ${amount} due {date}" |
| (Future) Large expense | Optional post: "{user} paid ${amount} for {description}" |

### Content Relationships

```
┌─────────────────────────────────────────────────────────────────┐
│                    ENTITY RELATIONSHIPS                          │
└─────────────────────────────────────────────────────────────────┘

     ┌──────────────────────────────────────────────────────┐
     │                      COMMUNITY                        │
     └──────────────────────────────────────────────────────┘
                │              │              │
                ▼              ▼              ▼
         ┌──────────┐   ┌──────────┐   ┌──────────┐
         │  Event   │   │   Post   │   │Transaction│
         └────┬─────┘   └────┬─────┘   └────┬─────┘
              │              │              │
     ┌────────┼────────┐     │         ┌────┼────┐
     ▼        ▼        ▼     ▼         ▼         ▼
  ┌─────┐ ┌─────┐ ┌───────┐ ┌───────┐ ┌─────┐ ┌─────┐
  │RSVP │ │Media│ │Comment│ │Reaction│ │Split│ │ Due │
  └─────┘ └─────┘ └───────┘ └───────┘ └─────┘ └─────┘
              │
              ▼
         ┌──────────┐
         │linked_   │◄─── Optional cross-references
         │event_id  │
         └──────────┘
```

---

## Community vs Personal Boundaries

### What Lives Where

| Content | Scope | Persists When... |
|---------|-------|------------------|
| User profile (name, avatar) | Account | User deletes account |
| Family members | Account | User deletes account |
| Notification preferences | Account | User deletes account |
| Community membership | Community | User leaves OR community deleted |
| Events | Community | Community deleted |
| Posts | Community | Author leaves (content stays) |
| Transactions | Community | Author leaves (content stays) |
| RSVPs | Community | Event deleted |
| Comments | Community | Post deleted |

### Member Leaves Community

When a user leaves (or is removed from) a community:

```
┌─────────────────────────────────────────────────────────────────┐
│                    MEMBER DEPARTURE                              │
└─────────────────────────────────────────────────────────────────┘

User leaves "Tigers Little League"

REMOVED:
├── Access to community
├── Ability to see content
├── Future notifications
└── Membership record (soft delete: left_at set)

PRESERVED (in community):
├── Posts they authored → shown as "Former Member" or name preserved
├── Comments they made → shown as "Former Member"
├── Expenses they logged → preserved with name
├── RSVPs they submitted → preserved
└── Historical audit trail

PRESERVED (in their account):
├── No reference to community content
└── Clean slate
```

### Community Deleted

When a community is deleted:

```
┌─────────────────────────────────────────────────────────────────┐
│                   COMMUNITY DELETION                             │
└─────────────────────────────────────────────────────────────────┘

Admin deletes "Tigers Little League"

SOFT DELETE (30-day grace period):
├── Community hidden from all members
├── All content preserved but inaccessible
├── Admin can restore during grace period
└── Members notified

HARD DELETE (after 30 days):
├── Community record deleted
├── All events deleted
├── All posts deleted
├── All transactions deleted
├── All media files deleted (Azure Blob)
├── Membership records deleted
└── Audit log retained (anonymized)
```

### User Account Deleted

When a user deletes their account:

```
┌─────────────────────────────────────────────────────────────────┐
│                    ACCOUNT DELETION                              │
└─────────────────────────────────────────────────────────────────┘

User requests account deletion

7-DAY GRACE PERIOD:
├── Account marked for deletion
├── User can log in and cancel
└── All functionality preserved

AFTER 7 DAYS:
├── User record anonymized
│   ├── apple_id → null
│   ├── email → "deleted-{uuid}@deleted.orbitcove.app"
│   ├── display_name → "Deleted User"
│   └── avatar_url → null
├── Family members deleted
├── Auth tokens revoked
├── Removed from all communities (but content preserved)
├── Notification records deleted
└── Personal data export (if requested) delivered before deletion
```

---

## Cross-Cutting Concepts

### Members

Members appear across all pillars:

```
┌─────────────────────────────────────────────────────────────────┐
│                     MEMBER PRESENCE                              │
└─────────────────────────────────────────────────────────────────┘

Member: "Sarah Johnson"
│
├── Calendar
│   ├── Created events (shown as creator)
│   ├── RSVPs (shown in attendee list)
│   └── Event reminders (receive notifications)
│
├── Feed
│   ├── Authored posts (profile shown)
│   ├── Comments (profile shown)
│   ├── Reactions (shown in reaction list)
│   ├── Poll votes (shown in results)
│   └── Mentions (can be @mentioned)
│
├── Finances
│   ├── Expenses paid (shown as payer)
│   ├── Splits owed (shown in split list)
│   ├── Balances (calculated per member)
│   └── Dues status (paid/unpaid)
│
└── Community
    ├── Member list (visible to all)
    ├── Role (admin badge if admin)
    └── Join date (visible in member detail)
```

### Family Members

Family members (parent-managed profiles) have limited presence:

```
┌─────────────────────────────────────────────────────────────────┐
│                  FAMILY MEMBER PRESENCE                          │
└─────────────────────────────────────────────────────────────────┘

Family Member: "Tommy" (managed by Sarah)
│
├── Calendar
│   └── RSVPs (can RSVP via parent)
│       └── Shows as "Tommy (via Sarah)"
│
├── Feed
│   └── No direct presence (parent posts on behalf)
│
├── Finances
│   └── No direct presence (parent handles)
│
└── Community
    └── Listed under parent's profile
```

### Timestamps & Timezones

All content shows contextual timestamps:

| Age | Display |
|-----|---------|
| < 1 minute | "Just now" |
| < 1 hour | "5m ago", "45m ago" |
| < 24 hours | "3h ago", "18h ago" |
| < 7 days | "Yesterday", "3 days ago" |
| < 1 year | "Jan 15", "Mar 22" |
| > 1 year | "Jan 15, 2025" |

**Timezone handling**:
- All times stored in UTC
- Displayed in user's device timezone
- Community can set default timezone (for event creation suggestions)

### Media (Photos/Files)

Media is attached to content, not standalone:

```
Media attachment points:
│
├── Events
│   └── Attachments (field maps, schedules)
│
├── Posts
│   └── Photos (up to 10 per post)
│
├── Transactions
│   └── Receipt photo (1 per transaction)
│
└── Profiles
    ├── User avatar
    ├── Family member avatars
    └── Community icon
```

---

## Search & Discovery

### Search Scope

Search is always within the current community:

```
┌─────────────────────────────────────────────────────────────────┐
│                      SEARCH SCOPE                                │
└─────────────────────────────────────────────────────────────────┘

Search in "Tigers Little League"
│
├── Events
│   ├── Title
│   ├── Description
│   └── Location name
│
├── Posts
│   ├── Content text
│   └── Author name
│
├── Members
│   ├── Display name
│   └── Nickname (if set)
│
└── Transactions (future)
    └── Description
```

### Search UI

```
┌─────────────────────────────────────┐
│  🔍 Search Tigers Little League     │
├─────────────────────────────────────┤
│                                     │
│  Recent Searches                    │
│  practice · pizza · tournament      │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  (Results appear as user types)     │
│                                     │
│  Events                             │
│  ┌─────────────────────────────────┐│
│  │ 📅 Practice - Jan 25            ││
│  │ 📅 Practice - Feb 1             ││
│  └─────────────────────────────────┘│
│                                     │
│  Posts                              │
│  ┌─────────────────────────────────┐│
│  │ 📝 "Great practice today!"      ││
│  │    Sarah J. · 2 days ago        ││
│  └─────────────────────────────────┘│
│                                     │
│  Members                            │
│  ┌─────────────────────────────────┐│
│  │ 👤 Coach Dan                    ││
│  └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

### Discovery (Finding Content)

Users find content through:

| Method | Description |
|--------|-------------|
| **Feed** | Chronological, pinned items at top |
| **Calendar** | Date-based navigation |
| **Notifications** | Pushed/pulled alerts |
| **Search** | Keyword lookup |
| **Deep links** | Direct navigation from push/share |

---

## Deep Linking Structure

### URL Scheme

```
orbitcove://                           # Open app
orbitcove://join/{code}                # Join community
orbitcove://community/{id}             # Open community
orbitcove://community/{id}/calendar    # Calendar tab
orbitcove://community/{id}/feed        # Feed tab
orbitcove://community/{id}/finances    # Finances tab
orbitcove://community/{id}/event/{id}  # Event detail
orbitcove://community/{id}/post/{id}   # Post detail
orbitcove://community/{id}/transaction/{id}  # Transaction detail
orbitcove://settings                   # App settings
orbitcove://notifications              # Notification center
```

### Universal Links

```
https://orbitcove.app/join/{code}      # Join community (works in browser too)
https://orbitcove.app/c/{id}           # Open community
https://orbitcove.app/c/{id}/e/{id}    # Event detail
https://orbitcove.app/c/{id}/p/{id}    # Post detail
```

### Push Notification Deep Links

| Notification Type | Deep Link |
|-------------------|-----------|
| New Event | `orbitcove://community/{id}/event/{eventId}` |
| RSVP Reminder | `orbitcove://community/{id}/event/{eventId}` |
| New Post | `orbitcove://community/{id}/post/{postId}` |
| Mention | `orbitcove://community/{id}/post/{postId}` |
| Comment | `orbitcove://community/{id}/post/{postId}` |
| Payment Request | `orbitcove://community/{id}/finances` |
| Dues Reminder | `orbitcove://community/{id}/finances` |

### Share Links

When sharing content outside the app:

**Event Share**:
```
Practice
Saturday, Jan 25 at 9:00 AM
Lincoln Park Field #3

RSVP on OrbitCove:
https://orbitcove.app/c/abc123/e/xyz789
```

**Community Invite**:
```
Join Tigers Little League on OrbitCove!

Use code: ABC123
Or tap: https://orbitcove.app/join/ABC123
```

---

## Content Lifecycle

### Content States

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONTENT LIFECYCLE                             │
└─────────────────────────────────────────────────────────────────┘

         ┌──────────┐
         │  Draft   │ (future: for long posts)
         └────┬─────┘
              │ Save
              ▼
         ┌──────────┐
         │ Pending  │ (offline, waiting to sync)
         └────┬─────┘
              │ Sync success
              ▼
         ┌──────────┐
         │  Active  │ (normal state)
         └────┬─────┘
              │
    ┌─────────┴─────────┐
    │                   │
    ▼                   ▼
┌──────────┐      ┌──────────┐
│ Archived │      │ Deleted  │
│ (future) │      │(soft del)│
└──────────┘      └────┬─────┘
                       │ 30 days
                       ▼
                  ┌──────────┐
                  │  Purged  │
                  │(hard del)│
                  └──────────┘
```

### Content Visibility Rules

| Content | Who Can See | Who Can Edit | Who Can Delete |
|---------|-------------|--------------|----------------|
| Event | All members | Creator, Admin | Creator, Admin |
| Post | All members | Author (24h), Admin | Author, Admin |
| Comment | All members | Author (24h) | Author, Admin |
| Transaction | Involved members | Creator (7d), Admin | Admin only |
| RSVP | All members | RSVP owner | RSVP owner |

### Soft Delete Behavior

When content is soft-deleted:

| Content Type | Display | Data |
|--------------|---------|------|
| Post | "[Post deleted]" placeholder | Preserved 30 days |
| Comment | "[Comment deleted]" | Preserved 30 days |
| Event | Removed from calendar | Preserved 30 days |
| Transaction | Removed from list, balances recalculated | Preserved 30 days |

### Sync Conflict Resolution

```
┌─────────────────────────────────────────────────────────────────┐
│                  CONFLICT RESOLUTION                             │
└─────────────────────────────────────────────────────────────────┘

Scenario: User edits event offline, someone else edits same event

Local:  "Practice at 9am" (edited offline at 10:00)
Server: "Practice at 10am" (edited by Coach at 10:05)

Resolution Options:

1. AUTOMATIC (most cases):
   └── Last-write-wins based on server timestamp
   └── Server version (10am) wins
   └── User notified: "Practice was updated"

2. MANUAL (conflicting edits to same field):
   └── User prompted to choose
   └── "Your version" vs "Current version"
   └── Selected version becomes canonical

3. MERGE (different fields edited):
   └── User changed title, Coach changed time
   └── Both changes merged automatically
```

---

## Information Architecture Diagram

### Complete IA Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ORBITCOVE INFORMATION ARCHITECTURE                   │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│  ACCOUNT LEVEL                                                               │
│  ─────────────                                                               │
│                                                                              │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐           │
│  │     Profile      │  │  Family Members  │  │  App Settings    │           │
│  │  ┌────────────┐  │  │  ┌────────────┐  │  │  ┌────────────┐  │           │
│  │  │ Name       │  │  │  │ Tommy      │  │  │  │ Appearance │  │           │
│  │  │ Avatar     │  │  │  │ Emma       │  │  │  │ Notifs     │  │           │
│  │  │ Email      │  │  │  │ ...        │  │  │  │ Privacy    │  │           │
│  │  └────────────┘  │  │  └────────────┘  │  │  └────────────┘  │           │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘           │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────┐           │
│  │                    Community Memberships                      │           │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │           │
│  │  │ Johnson     │  │ Tigers LL   │  │ Book Club   │           │           │
│  │  │ Family      │  │ (Admin)     │  │ (Member)    │           │           │
│  │  │ (Admin)     │  │             │  │             │           │           │
│  │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘           │           │
│  └─────────┼────────────────┼────────────────┼──────────────────┘           │
│            │                │                │                               │
└────────────┼────────────────┼────────────────┼───────────────────────────────┘
             │                │                │
             ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│  COMMUNITY LEVEL (repeated per community)                                    │
│  ───────────────                                                             │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  Community: Tigers Little League                                      │   │
│  │                                                                       │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐ │   │
│  │  │                         PILLARS                                  │ │   │
│  │  │                                                                  │ │   │
│  │  │  ┌────────────────┐ ┌────────────────┐ ┌────────────────┐       │ │   │
│  │  │  │   CALENDAR     │ │     FEED       │ │   FINANCES     │       │ │   │
│  │  │  │                │ │                │ │                │       │ │   │
│  │  │  │ ┌────────────┐ │ │ ┌────────────┐ │ │ ┌────────────┐ │       │ │   │
│  │  │  │ │   Events   │ │ │ │   Posts    │ │ │ │Transactions│ │       │ │   │
│  │  │  │ │  ┌───────┐ │ │ │ │  ┌───────┐ │ │ │ │  ┌───────┐ │ │       │ │   │
│  │  │  │ │  │ RSVPs │ │ │ │ │  │Comment│ │ │ │ │  │Splits │ │ │       │ │   │
│  │  │  │ │  └───────┘ │ │ │ │  │React  │ │ │ │ │  └───────┘ │ │       │ │   │
│  │  │  │ │            │ │ │ │  │Votes  │ │ │ │ │            │ │       │ │   │
│  │  │  │ │            │ │ │ │  └───────┘ │ │ │ │ ┌────────┐ │ │       │ │   │
│  │  │  │ └────────────┘ │ │ └────────────┘ │ │ │ │  Dues  │ │ │       │ │   │
│  │  │  │                │ │                │ │ │ │Payments│ │ │       │ │   │
│  │  │  │                │ │                │ │ │ └────────┘ │ │       │ │   │
│  │  │  └────────────────┘ └────────────────┘ └────────────────┘       │ │   │
│  │  │                                                                  │ │   │
│  │  └─────────────────────────────────────────────────────────────────┘ │   │
│  │                                                                       │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐ │   │
│  │  │                     COMMUNITY META                               │ │   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐         │ │   │
│  │  │  │ Members  │  │ Settings │  │ Invites  │  │  Media   │         │ │   │
│  │  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘         │ │   │
│  │  └─────────────────────────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 2026 | Claude | Initial draft |

---

*Next document: MVP Scope Definition*
