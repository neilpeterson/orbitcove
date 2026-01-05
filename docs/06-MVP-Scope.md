# OrbitCove - MVP Scope Definition

**Version**: 1.0 Draft
**Last Updated**: January 2026
**Status**: Review

---

## Table of Contents

1. [MVP Philosophy](#mvp-philosophy)
2. [What's In](#whats-in)
3. [What's Out](#whats-out)
4. [Feature Breakdown](#feature-breakdown)
5. [Target Users](#target-users)
6. [Technical Scope](#technical-scope)
7. [Launch Criteria](#launch-criteria)
8. [Post-MVP Roadmap](#post-mvp-roadmap)
9. [Risks & Mitigations](#risks--mitigations)

---

## MVP Philosophy

### Core Principle: Nail the Basics

The MVP must do three things exceptionally well:
1. **Calendar** that families and teams actually use
2. **Feed** that replaces group texts
3. **Finances** that eliminates "who owes what" confusion

We're not building six features poorly. We're building three features that make users say "I can't go back to the old way."

### Success Definition

MVP is successful if:
- A family uses OrbitCove for 30+ days without reverting to group texts
- A Little League team completes a full season using OrbitCove
- Users invite others without prompting

### What MVP is NOT

- A feature-complete product
- A competitor to every community app
- Suitable for large organizations (100+ members)
- Ready for enterprise/compliance requirements

---

## What's In

### Platform
| Component | MVP Scope |
|-----------|-----------|
| iOS App | Yes - SwiftUI, iOS 17+ |
| Android App | No |
| Web App | No |
| Backend API | Yes - Vapor on Azure |

### Feature Pillars
| Pillar | MVP Scope |
|--------|-----------|
| Shared Calendar | Yes - Full |
| Private Social Feed | Yes - Full |
| Shared Finances | Yes - Full |
| Password Vault | No - v2.0 |
| Photo Aggregation | No - v2.0 |
| Legacy/Memory | No - v2.5 |

### Business Model
| Component | MVP Scope |
|-----------|-----------|
| Free tier (≤3 members) | Yes |
| Paid tier (4+ members) | Yes |
| Stripe subscriptions | Yes |
| In-app purchases | No |

---

## What's Out

### Explicitly Excluded from MVP

| Feature | Reason | Target Version |
|---------|--------|----------------|
| Android app | Focus on iOS first | v1.5 |
| Web app | Mobile-first strategy | v2.0 |
| End-to-end encryption | Complexity vs. timeline | v1.1 |
| Password vault | Requires E2E, integration work | v2.0 |
| Photo albums | Storage costs, complexity | v2.0 |
| Legacy/memory features | Not core to daily use | v2.5 |
| Direct messages | Use iMessage, not competing | Never |
| Video/voice calls | Use FaceTime, not competing | Never |
| Public communities | Privacy-first = invite-only | TBD |
| Multi-language | English only for launch | v1.5 |
| Accessibility audit | Basic support only | v1.1 |
| Apple Watch app | Not essential | v2.0 |
| iPad optimization | iPhone-first | v1.5 |
| Widgets | Nice-to-have | v1.1 |
| Siri integration | Nice-to-have | v1.5 |

### Features Deferred Within MVP Pillars

| Pillar | Deferred Feature | Reason |
|--------|------------------|--------|
| Calendar | Google Calendar sync | Apple Calendar export sufficient |
| Calendar | Outlook sync | Apple Calendar export sufficient |
| Calendar | Recurring event exceptions | Complex, edge case |
| Feed | Link previews | Nice-to-have |
| Feed | File sharing (non-image) | Complexity |
| Feed | Post search | Can add quickly post-launch |
| Feed | Hashtags | Over-engineering |
| Finances | Apple Pay in-app | Stripe web checkout works |
| Finances | Automatic payment processing | Manual marking sufficient |
| Finances | Multi-currency | USD only for launch |
| Finances | Expense categories reports | Basic tracking sufficient |

---

## Feature Breakdown

### Calendar - MVP Features

| Feature | Included | Notes |
|---------|----------|-------|
| Create event | ✓ | Title, date/time, location, description |
| Edit/delete event | ✓ | Creator and admin |
| Recurring events | ✓ | Basic patterns (daily, weekly, monthly) |
| RSVP (yes/no/maybe) | ✓ | |
| RSVP for family members | ✓ | Parent can RSVP for kids |
| RSVP visibility | ✓ | See who's responded |
| RSVP reminders | ✓ | Auto-nudge non-responders |
| Event reminders | ✓ | Push notification before event |
| Location with maps | ✓ | Apple Maps integration |
| Add to Apple Calendar | ✓ | One-tap export |
| Month view | ✓ | |
| List view | ✓ | |
| Event categories | ✓ | Practice, Game, Meeting, Social, Other |
| Attachments | ✓ | Images only |
| Week view | ✗ | Post-MVP |
| ICS subscription | ✗ | Post-MVP |
| Google Calendar sync | ✗ | Post-MVP |

### Feed - MVP Features

| Feature | Included | Notes |
|---------|----------|-------|
| Text posts | ✓ | Basic formatting |
| Photo posts | ✓ | Up to 10 images |
| Announcements | ✓ | Admin-only, highlighted |
| Polls | ✓ | Multiple choice |
| Event auto-posts | ✓ | When event created |
| Reactions | ✓ | Like, Love, Laugh, Celebrate |
| Comments | ✓ | Single-level threading |
| @mentions | ✓ | Notify mentioned user |
| Pinned posts | ✓ | Admin can pin up to 3 |
| Chronological feed | ✓ | No algorithm |
| Edit post (24h) | ✓ | |
| Delete post | ✓ | Author or admin |
| Notification preferences | ✓ | Per-community |
| Link previews | ✗ | Post-MVP |
| File attachments | ✗ | Post-MVP |
| Search | ✗ | Post-MVP |
| Nested comment replies | ✗ | Post-MVP |

### Finances - MVP Features

| Feature | Included | Notes |
|---------|----------|-------|
| Add expense | ✓ | Amount, description, paid by |
| Receipt photo | ✓ | One image per expense |
| Equal split | ✓ | Divide evenly |
| Custom split | ✓ | Different amounts |
| Select split members | ✓ | Choose who participates |
| Running balance | ✓ | What you owe/are owed |
| Simplify debts | ✓ | Minimize transactions |
| Mark as settled | ✓ | Manual confirmation |
| Venmo deep link | ✓ | Pre-filled amount/recipient |
| Transaction history | ✓ | Full ledger |
| Set up dues | ✓ | Admin only |
| Track dues payments | ✓ | Who's paid status |
| Payment reminders | ✓ | Push notification |
| Expense categories | ✓ | Basic categories |
| Link expense to event | ✓ | Optional association |
| Apple Pay | ✗ | Post-MVP |
| Percentage split | ✗ | Post-MVP |
| Multi-currency | ✗ | Post-MVP |
| Expense reports | ✗ | Post-MVP |

### Community Management - MVP Features

| Feature | Included | Notes |
|---------|----------|-------|
| Create community | ✓ | Name, type, icon |
| Join via code | ✓ | 6-character code |
| Join via link | ✓ | Universal link |
| QR code invite | ✓ | Scannable |
| Share invite (text/email) | ✓ | Native share sheet |
| Member list | ✓ | |
| Admin/member roles | ✓ | Two roles only |
| Promote to admin | ✓ | |
| Remove member | ✓ | Admin only |
| Leave community | ✓ | |
| Community settings | ✓ | Basic preferences |
| Delete community | ✓ | Admin only, with confirmation |
| Multiple communities | ✓ | User can be in many |
| Community switcher | ✓ | Easy switching |
| Custom roles | ✗ | Post-MVP |
| Member permissions | ✗ | Post-MVP (beyond admin/member) |

### Account & Profile - MVP Features

| Feature | Included | Notes |
|---------|----------|-------|
| Sign in with Apple | ✓ | Primary auth |
| Email/password auth | ✗ | Apple-only for MVP |
| Edit profile | ✓ | Name, avatar |
| Add family members | ✓ | Managed profiles |
| Notification settings | ✓ | Global and per-community |
| Delete account | ✓ | With data export option |
| Data export | ✓ | GDPR compliance |
| Subscription management | ✓ | Via Stripe portal |
| Dark mode | ✓ | Follow system setting |
| Biometric lock | ✗ | Post-MVP |
| Multiple devices | ✓ | Same Apple ID |

---

## Target Users

### Primary: Families

**Ideal Family Profile**:
- 4-15 members (nuclear + extended)
- Mix of tech-savvy and less tech-savvy members
- Currently using group texts + shared calendars + Venmo
- At least one "family organizer" willing to set it up

**Key Use Cases**:
- Weekly family dinners
- Holiday planning
- Splitting vacation costs
- Coordinating grandparent visits
- Sharing photos after events

**Success Metric**: Family uses app weekly for 2+ months

### Primary: Little League Teams

**Ideal Team Profile**:
- 10-20 families (players + parents)
- Season-based (spring/fall)
- Coach or team parent willing to manage
- Currently using email + group text + paper signups + Venmo

**Key Use Cases**:
- Practice and game schedule
- Rain-out notifications
- Snack bar duty signups (via RSVP)
- Season dues collection
- Team photo sharing

**Success Metric**: Team completes full season on app

### Not Targeting (MVP)

| User Type | Why Not |
|-----------|---------|
| Large organizations (50+) | Need admin tools we don't have |
| Businesses/professional teams | Need invoicing, contracts |
| Public communities | Privacy-first = invite-only |
| Creator communities | Need monetization features |
| Schools/PTAs | Need compliance, vetting |

---

## Technical Scope

### Platform Requirements

| Requirement | MVP Spec |
|-------------|----------|
| iOS minimum | iOS 17.0 |
| Devices | iPhone only (iPad works but not optimized) |
| Orientation | Portrait only |
| Offline support | Full (read + queued writes) |
| Background refresh | Yes (for notifications) |

### Backend Requirements

| Requirement | MVP Spec |
|-------------|----------|
| API | REST, versioned (/api/v1/) |
| Auth | Azure AD B2C + Sign in with Apple |
| Database | PostgreSQL (Azure Flexible Server) |
| Storage | Azure Blob Storage |
| CDN | Azure Front Door |
| Push | Azure Notification Hubs |
| Encryption | TLS 1.3 + Azure at-rest |

### Scale Targets (Launch)

| Metric | Target |
|--------|--------|
| Concurrent users | 1,000 |
| Total communities | 5,000 |
| Total users | 25,000 |
| Events per community | 500 |
| Posts per community | 2,000 |
| Media storage | 100 GB |

### Performance Targets

| Metric | Target |
|--------|--------|
| App launch (cold) | < 2 seconds |
| App launch (warm) | < 0.5 seconds |
| Feed load | < 1 second |
| Event creation | < 0.5 seconds (local) |
| Image upload | < 3 seconds (5MB) |
| Push delivery | < 5 seconds |

---

## Launch Criteria

### Must Have (Launch Blockers)

- [ ] All MVP features functional
- [ ] No critical/high severity bugs
- [ ] App Store approval
- [ ] Privacy policy published
- [ ] Terms of service published
- [ ] Stripe subscriptions working
- [ ] Push notifications working
- [ ] Basic analytics in place
- [ ] Error tracking (Sentry or similar)
- [ ] Data backup and recovery tested
- [ ] Load tested to 2x scale targets

### Should Have (Launch Preferred)

- [ ] Onboarding tutorial/tips
- [ ] Empty state illustrations
- [ ] App Store screenshots and description
- [ ] Landing page (orbitcove.app)
- [ ] Support email configured
- [ ] FAQ/help documentation
- [ ] TestFlight beta completed (50+ users)

### Nice to Have (Can Launch Without)

- [ ] Video walkthrough
- [ ] Press kit
- [ ] Social media accounts
- [ ] Blog/content

---

## Post-MVP Roadmap

### v1.1 - Polish & Security

**Timeline**: 4-6 weeks after launch

| Feature | Priority |
|---------|----------|
| End-to-end encryption | P0 |
| iOS widgets (calendar, feed) | P1 |
| Week view for calendar | P1 |
| Post search | P1 |
| Link previews | P2 |
| Accessibility audit fixes | P1 |
| Performance optimizations | P1 |
| Bug fixes from launch feedback | P0 |

### v1.5 - Platform Expansion

**Timeline**: 3-4 months after launch

| Feature | Priority |
|---------|----------|
| Android app | P0 |
| iPad optimization | P1 |
| Google Calendar sync | P1 |
| Multi-language (Spanish first) | P2 |
| Siri shortcuts | P2 |
| ICS calendar subscription | P2 |

### v2.0 - New Pillars

**Timeline**: 6-8 months after launch

| Feature | Priority |
|---------|----------|
| Password/credentials vault | P0 |
| Photo albums/aggregation | P0 |
| Web app (view-only initially) | P1 |
| Apple Pay in-app payments | P2 |
| Advanced expense reports | P2 |

### v2.5 - Legacy Features

**Timeline**: 10-12 months after launch

| Feature | Priority |
|---------|----------|
| Document storage | P1 |
| Group timeline | P1 |
| Memorial spaces | P2 |
| Recipe/tradition docs | P2 |
| Family tree visualization | P2 |

---

## Risks & Mitigations

### Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Offline sync conflicts | High | Medium | Simple last-write-wins, test extensively |
| Push notification reliability | Medium | High | Fallback to in-app indicators, email digest option |
| Azure cost overruns | Medium | Medium | Cost alerts, usage monitoring, reserved instances |
| App Store rejection | Low | High | Follow guidelines strictly, prepare appeal |
| Vapor ecosystem gaps | Medium | Medium | Identify dependencies early, fallback to .NET |

### Product Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Too complex for "grandma" | Medium | High | User testing with non-tech users, simplify ruthlessly |
| Feature creep delays launch | High | High | Strict scope control, "post-MVP" parking lot |
| Low invite conversion | Medium | High | Optimize invite flow, test messaging |
| Users don't pay | Medium | High | Value must be obvious before paywall |
| Competitor launches similar | Low | Medium | Move fast, focus on execution |

### Market Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| BAND/TeamSnap improves | Medium | Medium | Differentiate on all-in-one + privacy |
| Apple launches competitor | Low | High | Build loyal user base, pivot if needed |
| Recession reduces discretionary spend | Medium | Medium | Keep pricing low, emphasize value |

---

## Decision Log

| Decision | Date | Rationale |
|----------|------|-----------|
| iOS-only for MVP | Jan 2026 | Faster to market, SwiftUI expertise |
| Vapor over .NET | Jan 2026 | Code sharing with iOS, single language |
| TLS-only encryption for MVP | Jan 2026 | E2E adds 4-6 weeks, can add in v1.1 |
| Three pillars only | Jan 2026 | Focus on doing fewer things better |
| Families + Little League | Jan 2026 | Clear use cases, testable communities |
| Free ≤3 members | Jan 2026 | Let families try before paying |
| Stripe web checkout | Jan 2026 | Avoid 30% Apple fee on subscriptions |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 2026 | Claude | Initial draft |

---

*Next document: Development Roadmap*
