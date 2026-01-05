# OrbitCove - Product Requirements Document (PRD)

**Version**: 1.0 Draft
**Last Updated**: January 2026
**Status**: Review

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Problem Statement](#problem-statement)
3. [Target Users](#target-users)
4. [Product Principles](#product-principles)
5. [Feature Specifications](#feature-specifications)
   - [MVP Features (v1.0)](#mvp-features-v10)
   - [Post-MVP Features (v2.0+)](#post-mvp-features-v20)
6. [User Stories](#user-stories)
7. [Success Metrics](#success-metrics)
8. [Non-Functional Requirements](#non-functional-requirements)
9. [Out of Scope](#out-of-scope)
10. [Open Questions](#open-questions)

---

## Executive Summary

**OrbitCove** is a privacy-first, all-in-one community platform for iOS that enables any group—families, sports teams, clubs—to create their own private digital space with integrated organizational tools.

### MVP Scope
- **Platform**: iOS (SwiftUI), Azure backend
- **Core Pillars**: Shared Calendar, Private Social Feed, Shared Finances
- **Target Users**: Families (immediate/extended) and Little League baseball teams
- **Business Model**: Freemium (3 communities free, paid upgrades for more + premium features)

### Differentiator
One app replaces five. Instead of juggling GroupMe + Google Calendar + Splitwise + shared notes + photo albums, OrbitCove provides a unified, private space designed for real communities—not corporations or creators.

---

## Problem Statement

### Current Pain Points

**For Families:**
- Coordination scattered across group texts, shared calendars, Venmo requests, and Google Photos albums
- No single place for "family knowledge" (WiFi passwords, account logins, traditions, recipes)
- Extended family coordination is especially fragmented
- Privacy concerns with big tech platforms mining family data

**For Little League Teams:**
- Parents juggle multiple apps: TeamSnap for schedule, Venmo for dues, GroupMe for chat, email for announcements
- Coaches waste time on admin instead of coaching
- No clean way to share team photos without everyone having to manually share
- Season-end: all that history disappears or is locked in someone's personal account

### Why Existing Solutions Fail

| Solution | Problem |
|----------|---------|
| **GroupMe/WhatsApp** | Chat only. No calendar, finances, or organization. Becomes noise. |
| **Google Calendar** | Shared calendars work but no social, financial, or community features. |
| **Splitwise** | Finances only. Separate app, separate mental model. |
| **TeamSnap** | Sports-specific, expensive ($10+/mo for teams), corporate feel. |
| **BAND** | Cluttered UI, poor UX, feels dated. 500M downloads but low engagement. |
| **Facebook Groups** | Privacy nightmare. Ads. Older demographic resistant. |
| **Discord** | Gaming-oriented. Parents/families find it confusing. |

---

## Target Users

### Primary Personas (MVP Focus)

#### Persona 1: "Family Coordinator" - Sarah, 42
- **Role**: Mom of 3, manages household and extended family
- **Community Size**: 8-25 people (immediate + extended family)
- **Current Tools**: Family group text, shared Apple calendar, Venmo, Google Photos shared album, Notes app for passwords
- **Pain Points**:
  - Constantly answering "what's the WiFi password?" and "when is Thanksgiving dinner?"
  - Can't easily split costs for group gifts or family trips
  - Photos from family events scattered across everyone's phones
  - Aging parents need access to important documents
- **Success Criteria**: One app the whole family actually uses

#### Persona 2: "Team Manager" - Mike, 38
- **Role**: Little League coach, also a parent on the team
- **Community Size**: 15-25 people (12 kids + parents)
- **Current Tools**: Email, group text, paper signup sheets, Venmo for dues, personal phone for team photos
- **Pain Points**:
  - Spends more time on logistics than coaching
  - Chasing down families for dues payments
  - RSVPs are unreliable (people forget to respond)
  - No good way to share team photos with all families
- **Success Criteria**: All team coordination in one place, parents actually respond to things

#### Persona 3: "Community Member" - Jennifer, 35
- **Role**: Parent of Little Leaguer, also part of extended family group
- **Community Size**: Member of 2-4 communities
- **Current Tools**: Whatever the coordinator tells her to use
- **Pain Points**:
  - Too many apps to keep track of
  - Notifications scattered everywhere
  - Never knows where to look for the schedule
- **Success Criteria**: One app for all her group memberships, easy to use

### Secondary Personas (Post-MVP)
- Club organizer (book clubs, hobby groups)
- Church group coordinator
- Neighborhood association admin
- Friend group planner

---

## Product Principles

### 1. Privacy is Non-Negotiable
- No advertising, ever
- No selling user data, ever
- End-to-end encryption for sensitive content (messages, passwords, documents)
- GDPR and CCPA compliant from day one
- Users own their data; export and deletion must be easy

### 2. Simplicity Over Features
- A family member who "isn't good with technology" should be able to use this
- Every feature must justify its complexity
- Progressive disclosure: power features exist but don't clutter the basic experience
- Onboarding should take under 2 minutes

### 3. Community-First Design
- The community is the atomic unit, not the individual
- Content belongs to the community, not to whoever posted it
- When someone leaves, the community's history remains intact
- Roles and permissions should be simple: Admin, Member (avoid complex hierarchies)

### 4. All-in-One but Not Overwhelming
- The 6 pillars should feel integrated, not like 6 separate apps stitched together
- Cross-pillar features: e.g., create an event, it appears in calendar AND feed
- Unified notification strategy (not 6 different notification types)

---

## Feature Specifications

### MVP Features (v1.0)

---

#### Pillar 1: Shared Calendar

**Overview**: A shared calendar for community events with RSVP tracking and sync capabilities.

##### 1.1 Event Management

| Feature | Description | Priority |
|---------|-------------|----------|
| Create Event | Title, date/time, location, description, optional end time | P0 |
| Edit/Delete Event | Only admins and event creator can modify | P0 |
| Recurring Events | Daily, weekly, biweekly, monthly, custom patterns | P0 |
| Location Integration | Apple Maps integration for location selection and navigation | P0 |
| Event Categories | Color-coded types: Practice, Game, Meeting, Social, Other | P1 |
| Attachments | Add files/images to events (directions, field maps) | P1 |
| Reminders | Push notification reminders (1 hour, 1 day, 1 week before) | P0 |

##### 1.2 RSVP System

| Feature | Description | Priority |
|---------|-------------|----------|
| RSVP Options | Yes, No, Maybe | P0 |
| RSVP Visibility | All members see who's responded and how | P0 |
| RSVP Reminders | Auto-remind members who haven't responded | P0 |
| Plus-Ones | "Yes, bringing 2 guests" option | P1 |
| RSVP Deadline | Optional deadline after which RSVPs lock | P2 |
| Headcount Display | "8 Yes, 2 No, 3 Maybe, 5 No Response" summary | P0 |

##### 1.3 Calendar Views

| Feature | Description | Priority |
|---------|-------------|----------|
| Month View | Traditional calendar grid | P0 |
| List View | Chronological list of upcoming events | P0 |
| Week View | 7-day view with time slots | P1 |
| Today Widget | iOS widget showing today's events | P1 |

##### 1.4 Calendar Sync

| Feature | Description | Priority |
|---------|-------------|----------|
| Export to Apple Calendar | One-tap add event to personal calendar | P0 |
| Subscribe to Calendar | ICS feed URL for calendar subscription | P1 |
| Google Calendar Sync | Two-way sync with Google Calendar | P2 |

##### 1.5 Calendar-Specific Rules

- Events are visible to all community members
- Only Admins can create events by default (configurable per community)
- Past events remain visible for reference
- Events can be linked to financial items (e.g., "Game Day - $10 snack bar contribution")

---

#### Pillar 2: Private Social Feed

**Overview**: A private, chronological feed for community updates, announcements, and discussions.

##### 2.1 Post Types

| Post Type | Description | Priority |
|-----------|-------------|----------|
| Text Post | Plain text with optional formatting (bold, italic, lists) | P0 |
| Photo Post | Single or multiple images with optional caption | P0 |
| Announcement | Highlighted/pinned post from admins | P0 |
| Poll | Multiple choice question with voting | P0 |
| Event Share | When event is created, auto-posts to feed | P0 |
| Link Preview | Shared URLs show preview card | P1 |
| File Share | PDF, documents (practice schedule, roster) | P1 |

##### 2.2 Engagement

| Feature | Description | Priority |
|---------|-------------|----------|
| Reactions | Like, Love, Laugh, Celebrate (emoji-based) | P0 |
| Comments | Threaded comments on posts | P0 |
| @Mentions | Tag specific members in posts/comments | P0 |
| @Everyone | Notify all members (admin only by default) | P0 |
| Edit Post | Author can edit within 24 hours | P1 |
| Delete Post | Author and admins can delete | P0 |

##### 2.3 Feed Organization

| Feature | Description | Priority |
|---------|-------------|----------|
| Chronological Feed | Newest first, no algorithmic sorting | P0 |
| Pinned Posts | Admins can pin up to 3 posts | P0 |
| Announcement Banner | Latest announcement shows at top | P0 |
| Search | Search posts by keyword | P1 |
| Filter by Type | Show only photos, only polls, etc. | P2 |

##### 2.4 Notifications

| Feature | Description | Priority |
|---------|-------------|----------|
| New Post | Notify on new posts (configurable) | P0 |
| Mentions | Always notify when mentioned | P0 |
| Comments on My Post | Notify when someone comments | P0 |
| Replies to My Comment | Notify on replies | P0 |
| Announcement | Always notify on announcements | P0 |
| Digest Option | Daily digest instead of real-time | P1 |

##### 2.5 Feed-Specific Rules

- All members can post by default (configurable to admin-only)
- No editing after 24 hours (preserves integrity)
- Deleted posts show "[Post deleted]" placeholder to maintain thread context
- Images are compressed for storage but original quality downloadable
- Feed content is encrypted at rest

---

#### Pillar 3: Shared Finances

**Overview**: Transparent group expense tracking, bill splitting, and dues collection.

##### 3.1 Expense Tracking

| Feature | Description | Priority |
|---------|-------------|----------|
| Add Expense | Amount, description, date, paid by, split between | P0 |
| Receipt Upload | Photo of receipt attached to expense | P0 |
| Expense Categories | Customizable categories (Equipment, Food, Travel, Dues, Other) | P1 |
| Recurring Expenses | Monthly dues, subscription tracking | P1 |
| Expense Editing | Edit within 7 days, admin can edit anytime | P0 |

##### 3.2 Bill Splitting

| Feature | Description | Priority |
|---------|-------------|----------|
| Equal Split | Divide evenly among selected members | P0 |
| Custom Split | Different amounts per person | P0 |
| Percentage Split | Split by percentage | P1 |
| Exclude Members | Easy to exclude non-participating members | P0 |
| Split by Shares | "2 shares for adults, 1 for kids" | P2 |

##### 3.3 Balance Tracking

| Feature | Description | Priority |
|---------|-------------|----------|
| Running Balance | Each member sees what they owe/are owed | P0 |
| Simplify Debts | Reduce number of transactions needed to settle | P0 |
| Settlement Suggestions | "You owe Mike $25" with payment button | P0 |
| Transaction History | Full ledger of all transactions | P0 |
| Balance Summary | Dashboard view of all member balances | P0 |

##### 3.4 Payment Integration

| Feature | Description | Priority |
|---------|-------------|----------|
| Mark as Paid | Manual confirmation of payment | P0 |
| Venmo Deep Link | Open Venmo with pre-filled amount and recipient | P0 |
| Apple Pay | In-app payment via Apple Pay | P1 |
| Payment Reminders | Nudge members who owe money | P0 |
| Payment Confirmation | Both parties confirm to close transaction | P1 |

##### 3.5 Dues Collection (Team Feature)

| Feature | Description | Priority |
|---------|-------------|----------|
| Set Up Dues | Define amount and due date | P0 |
| Track Payment Status | Visual tracker of who's paid | P0 |
| Send Reminders | Bulk remind unpaid members | P0 |
| Payment Deadline | Optional late notification | P1 |
| Partial Payments | Track partial payments toward balance | P2 |

##### 3.6 Finance-Specific Rules

- All financial data is end-to-end encrypted
- Only members involved in a transaction see the details
- Admins see aggregate summaries, not individual transactions (unless involved)
- Full audit trail for disputes
- Data export available for tax purposes

---

### Post-MVP Features (v2.0+)

These pillars are defined at high level for architectural planning but will be fully specified before implementation.

---

#### Pillar 4: Shared Passwords/Credentials (v2.0)

**Overview**: Secure vault for shared accounts (Netflix, WiFi, etc.) via integration with established password manager.

**Integration Approach**: Partner with Bitwarden (open source, API available) or 1Password (better UX, established family plans).

**High-Level Features**:
- Shared vault per community
- Items: Username/password, WiFi networks, secure notes, credit cards
- Role-based access (some credentials admin-only)
- Auto-generate secure passwords
- E2E encryption (industry-standard implementation via partner)
- Breach monitoring alerts

**Technical Considerations**:
- Must feel native, not like a separate app
- Bitwarden SDK for iOS available
- Would require backend integration with vault service
- Zero-knowledge architecture required

---

#### Pillar 5: Photo Aggregation (v2.0)

**Overview**: Shared photo library that automatically collects and organizes photos from events.

**High-Level Features**:
- Shared albums per community
- Event-linked albums (auto-created when event happens)
- Bulk upload from camera roll (select date range)
- Automatic deduplication
- Optional: Face recognition for tagging (on-device processing for privacy)
- Download albums as ZIP
- Slideshow/memory reel generation

**Technical Considerations**:
- Storage costs are significant—tier limits needed
- On-device ML for face recognition (Core ML)
- Original quality vs. compressed storage tiers
- CDN for fast photo loading

---

#### Pillar 6: Legacy/Memory Preservation (v2.5)

**Overview**: Long-term storage for important documents and group history.

**High-Level Features**:
- Document storage (wills, insurance, property docs)
- Group timeline (auto-generated from events and posts)
- Memorial spaces for deceased members
- Recipe/tradition documentation
- Family tree visualization
- Export entire community archive

**Technical Considerations**:
- Long-term storage reliability critical
- Document encryption at rest
- Consider integration with iCloud for backup
- Memorial features require sensitivity in UX

---

## User Stories

### Community Creation & Onboarding

| ID | As a... | I want to... | So that... | Priority |
|----|---------|--------------|------------|----------|
| U-01 | New user | Sign up with Apple ID | I can get started quickly without another password | P0 |
| U-02 | New user | Create a community with a name and optional icon | My family/team has a home base | P0 |
| U-03 | Community admin | Invite members via link, text, or email | Others can join my community | P0 |
| U-04 | Invited user | Join a community with a 6-digit code | Joining is simple and secure | P0 |
| U-05 | New member | See a quick tour of features | I know how to use the app | P1 |
| U-06 | User | Be a member of multiple communities | I can be in my family AND my kid's team | P0 |
| U-07 | User | Switch between communities easily | I can access the right content quickly | P0 |

### Calendar Stories

| ID | As a... | I want to... | So that... | Priority |
|----|---------|--------------|------------|----------|
| C-01 | Admin | Create a game with date, time, and location | The team knows when and where to be | P0 |
| C-02 | Admin | Set up recurring weekly practices | I don't have to create each one manually | P0 |
| C-03 | Member | RSVP to events | The organizer knows I'm coming | P0 |
| C-04 | Admin | See who has and hasn't responded | I can follow up with non-responders | P0 |
| C-05 | Member | Add an event to my personal Apple Calendar | I see it alongside my other commitments | P0 |
| C-06 | Member | Get reminders before events | I don't forget to show up | P0 |
| C-07 | Admin | Attach a map/directions to an event | Parents can find the field easily | P1 |
| C-08 | Member | See past events | I can reference what happened when | P1 |

### Social Feed Stories

| ID | As a... | I want to... | So that... | Priority |
|----|---------|--------------|------------|----------|
| F-01 | Admin | Post an announcement | Everyone sees important news prominently | P0 |
| F-02 | Member | Post a photo with caption | I can share moments with the group | P0 |
| F-03 | Member | React to posts | I can engage without typing a comment | P0 |
| F-04 | Member | Comment on posts | I can participate in discussions | P0 |
| F-05 | Admin | Create a poll | I can get group input on decisions | P0 |
| F-06 | Member | @mention someone | They get notified and can respond | P0 |
| F-07 | Admin | Pin important posts | Key info stays visible | P0 |
| F-08 | Member | Control my notification preferences | I'm not overwhelmed but don't miss important things | P1 |

### Finance Stories

| ID | As a... | I want to... | So that... | Priority |
|----|---------|--------------|------------|----------|
| $-01 | Member | Add an expense I paid for | I can get reimbursed by the group | P0 |
| $-02 | Member | Split an expense among specific people | Only those who participated pay | P0 |
| $-03 | Member | See my current balance | I know what I owe or am owed | P0 |
| $-04 | Member | Mark a debt as settled | The balance is updated | P0 |
| $-05 | Admin | Set up season dues | Families know what to pay | P0 |
| $-06 | Admin | See who's paid dues | I can follow up on outstanding payments | P0 |
| $-07 | Member | Get a deep link to Venmo | I can pay with one tap | P0 |
| $-08 | Member | See the full transaction history | I can verify everything is accurate | P0 |
| $-09 | Admin | Send payment reminders | I don't have to manually chase people | P0 |

### Account & Settings Stories

| ID | As a... | I want to... | So that... | Priority |
|----|---------|--------------|------------|----------|
| A-01 | User | Edit my profile (name, photo) | Others know who I am | P0 |
| A-02 | Admin | Remove a member | They no longer have access | P0 |
| A-03 | Admin | Promote a member to admin | They can help manage | P0 |
| A-04 | Member | Leave a community | I'm no longer associated | P0 |
| A-05 | User | Delete my account | My personal data is removed | P0 |
| A-06 | Admin | Delete a community | Everything is removed if no longer needed | P1 |
| A-07 | User | Export my data | I have a copy of everything | P1 |

---

## Success Metrics

### North Star Metric
**Weekly Active Communities (WAC)**: Number of communities with 2+ members active in the last 7 days.

*Rationale*: A community is only valuable if it's actually being used by the group. Individual DAU matters less than group engagement.

### Primary Metrics

| Metric | Definition | Target (6 mo post-launch) |
|--------|------------|---------------------------|
| Weekly Active Communities | Communities with 2+ active members/week | 10,000 |
| Community Retention | % of communities active after 30 days | 60% |
| Member Retention | % of members active after 30 days | 50% |
| Avg. Events/Community/Month | Average calendar events created | 4+ |
| Avg. Posts/Community/Week | Average feed posts | 3+ |

### Secondary Metrics

| Metric | Definition | Target |
|--------|------------|--------|
| Invite Conversion | % of invites that result in signups | 40% |
| RSVP Response Rate | % of event RSVPs completed | 70% |
| Expense Settlement Rate | % of expenses settled within 7 days | 60% |
| Multi-Community Users | % of users in 2+ communities | 25% |
| App Store Rating | Average rating | 4.5+ |

### Financial Metrics

| Metric | Definition | Target (12 mo) |
|--------|------------|----------------|
| Free to Paid Conversion | % of users who upgrade | 5% |
| Monthly Recurring Revenue | Subscription revenue | TBD based on pricing |
| Customer Acquisition Cost | Marketing spend / new users | < $5 |
| Lifetime Value | Revenue per user over lifetime | > $25 |

---

## Non-Functional Requirements

### Performance

| Requirement | Target |
|-------------|--------|
| App launch time | < 2 seconds |
| Feed load time | < 1 second |
| Image upload | < 3 seconds for 5MB image |
| Push notification delivery | < 5 seconds |
| Offline support | View cached content, queue actions |

### Security

| Requirement | Implementation |
|-------------|----------------|
| Authentication | Sign in with Apple (primary), email/password (secondary) |
| Data encryption in transit | TLS 1.3 |
| Data encryption at rest | AES-256 |
| E2E encryption | Signal protocol for messages, financial data |
| Session management | 30-day refresh tokens, immediate revocation capability |
| Audit logging | All admin actions logged |

### Privacy & Compliance

| Requirement | Implementation |
|-------------|----------------|
| GDPR compliance | Full data export, right to deletion, consent management |
| CCPA compliance | Do-not-sell, data access requests |
| Data minimization | Only collect what's necessary |
| Third-party data sharing | None except essential services (Azure, payment processors) |
| Privacy policy | Clear, readable, accessible in-app |
| Age requirement | 13+ (COPPA compliance) |

### Reliability

| Requirement | Target |
|-------------|--------|
| Uptime | 99.9% (8.7 hours downtime/year max) |
| Data durability | 99.999999999% (11 nines) |
| Backup frequency | Daily with point-in-time recovery |
| Disaster recovery | RTO < 4 hours, RPO < 1 hour |

### Scalability (Initial Targets)

| Dimension | Target |
|-----------|--------|
| Concurrent users | 10,000 |
| Communities | 100,000 |
| Events per community | 1,000 |
| Posts per community | 10,000 |
| Members per community | 500 |

---

## Out of Scope (v1.0)

The following are explicitly NOT in v1.0 to maintain focus:

- **Android app** - iOS only for MVP
- **Web app** - Mobile only for MVP
- **Video/voice calling** - Use existing tools (FaceTime, Zoom)
- **Direct messaging** - Community-only, no 1:1 DMs (use iMessage)
- **Marketplace/selling** - No e-commerce features
- **Public communities** - All communities are private/invite-only
- **API for third parties** - No public API
- **White-labeling** - No custom branding for organizations
- **In-app payments beyond Apple Pay** - No Stripe checkout flows
- **Multi-language support** - English only for MVP
- **Password vault** - v2.0 feature
- **Photo aggregation** - v2.0 feature
- **Legacy/memory features** - v2.5 feature

---

## Resolved Decisions

### Pricing Model
- **Free tier**: Up to 3 members per community
- **Paid tier**: 4+ members requires subscription (price TBD, likely $4.99-$9.99/mo)
- **Who pays**: Community admin pays for the subscription
- **Multiple communities**: Each community evaluated independently

### Youth Accounts
- **Parent-managed accounts**: Children on teams are represented by their parent's account
- **Implementation**: Parent can add "family members" to their profile who appear as separate names in RSVP, attendance, etc., but notifications and access go through the parent
- **Future consideration**: Teen accounts (13+) with parental consent in later versions

### Content & Privacy
- **E2E encryption**: All content is end-to-end encrypted, not just financial data
- **Community discovery**: Invite-only (no public directory)
- **Content moderation**: Community admins responsible; report/block functionality for members

## Open Questions (Remaining)

### Technical Questions (to be resolved in Architecture doc)

1. **Offline mode depth**: Cache read-only, or allow offline writes that sync?
2. **Push notification provider**: Azure Notification Hubs vs. Firebase Cloud Messaging?
3. **Image storage**: Azure Blob vs. integrated CDN solution?

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 2026 | Claude | Initial draft |

---

*This document is a living specification. Updates will be tracked in version control.*
