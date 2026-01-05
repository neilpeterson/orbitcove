# OrbitCove - Development Roadmap

**Version**: 1.0 Draft
**Last Updated**: January 2026
**Status**: Review

---

## Table of Contents

1. [Overview](#overview)
2. [Phase Summary](#phase-summary)
3. [Phase 0: Foundation](#phase-0-foundation)
4. [Phase 1: Core Infrastructure](#phase-1-core-infrastructure)
5. [Phase 2: Calendar Pillar](#phase-2-calendar-pillar)
6. [Phase 3: Feed Pillar](#phase-3-feed-pillar)
7. [Phase 4: Finances Pillar](#phase-4-finances-pillar)
8. [Phase 5: Polish & Integration](#phase-5-polish--integration)
9. [Phase 6: Launch Prep](#phase-6-launch-prep)
10. [Critical Path](#critical-path)
11. [Dependencies](#dependencies)
12. [Resource Requirements](#resource-requirements)
13. [Risk Buffer](#risk-buffer)

---

## Overview

### Approach

Development follows a **UI-first methodology** organized into **5 phases**. All iOS screens are built with mock data before backend development begins, allowing rapid UI iteration and early validation.

### Methodology

- **UI-first**: Build all screens with mock data, then connect to real API
- **Protocol-based services**: Easy swap between mock and real implementations
- **Continuous integration**: Main branch always deployable
- **Weekly milestones**: Demonstrable progress each week
- **SwiftUI previews**: All screens previewable without running app

### Key Milestones

| Milestone | Description |
|-----------|-------------|
| M1: iOS Project | Xcode project builds, structure in place |
| M2: Navigation Shell | Tab bar, community switcher working with mock data |
| M3: All Screens | Every screen from UX Flows implemented |
| M4: Backend Running | Vapor API deployed to Azure staging |
| M5: Auth Working | Sign in with Apple end-to-end |
| M6: Full Integration | All features connected to real API |
| M7: Beta Ready | Offline sync, polish complete |
| M8: TestFlight | External beta testing |
| M9: Launch | App Store release |

---

## Phase Summary

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DEVELOPMENT PHASES (UI-FIRST)                             │
└─────────────────────────────────────────────────────────────────────────────┘

Phase 0: iOS Setup
├── Xcode project, SwiftData models, mock data framework
└── Deliverable: App builds, previews work

Phase 1: UI Mockups
├── All screens with mock data (no backend needed)
├── Onboarding, Calendar, Feed, Finances, Profile
└── Deliverable: Complete UI prototype, fully navigable

Phase 2: Backend Setup
├── Vapor project, Azure infrastructure, auth
└── Deliverable: API deployed, auth working

Phase 3: API Integration
├── Connect iOS to real API, replace mock services
└── Deliverable: All features work with real data

Phase 4: Polish & Offline
├── Offline sync, error handling, performance
└── Deliverable: Beta-ready app

Phase 5: Launch Prep
├── Beta testing, bug fixes, App Store submission
└── Deliverable: Launched app
```

### Benefits of UI-First

| Benefit | Description |
|---------|-------------|
| Fast iteration | SwiftUI previews update instantly |
| Early validation | Test UX before backend investment |
| Parallel work | Designer/developer can work on UI while planning backend |
| Clear API contract | UI reveals exactly what data backend needs |
| Stakeholder demos | Show working prototype without backend |

---

## Phase 0: iOS Setup

### Objective
Set up iOS project with architecture that supports mock data for UI development.

### Deliverables
- [ ] iOS project created with SwiftUI, SwiftData
- [ ] Project structure in place
- [ ] SwiftData models defined
- [ ] Mock data framework ready
- [ ] Theme/design system established

### Tasks

#### Project Setup
| Task | Description |
|------|-------------|
| Create Xcode project | SwiftUI app, iOS 17 target, bundle ID |
| Project structure | Features/, Core/, Shared/ directories |
| SwiftData setup | Model container, all entity models |
| SwiftLint | Linting rules configured |
| Unit test target | XCTest configured |
| Asset catalog | App icon placeholder, colors, SF Symbols |

#### Architecture Setup
| Task | Description |
|------|-------------|
| Service protocols | Define protocols for all services |
| Mock services | Implement mock versions returning static data |
| Dependency injection | Environment-based service injection |
| App entry point | OrbitCoveApp.swift with proper setup |

#### SwiftData Models
| Task | Description |
|------|-------------|
| User model | Profile, family members |
| Community model | Name, icon, settings, members |
| Event model | All calendar event fields |
| Post model | All feed post fields |
| Transaction model | Expenses, splits, dues |

#### Theme & Design System
| Task | Description |
|------|-------------|
| Colors | Define color palette (light/dark) |
| Typography | Define text styles |
| Spacing | Define spacing constants |
| Components | Button styles, card styles |

### Exit Criteria
- [ ] `xcodebuild` succeeds
- [ ] SwiftUI previews render with mock data
- [ ] All SwiftData models compile
- [ ] Mock services return sample data

---

## Phase 1: UI Mockups

### Objective
Build all iOS screens with mock data. Complete UI prototype without backend.

### Deliverables
- [ ] All screens from UX Flows document implemented
- [ ] Full navigation working
- [ ] Mock data displayed throughout
- [ ] SwiftUI previews for every screen

### Tasks

#### Onboarding & Auth Screens
| Task | Description |
|------|-------------|
| Welcome screen | App intro, Get Started button |
| Sign in screen | Sign in with Apple button (mock auth) |
| Create community | Name, type selection, icon |
| Join community | Code entry, QR scanner placeholder |
| Invite members | Share sheet, code display |

#### Navigation Shell
| Task | Description |
|------|-------------|
| Tab bar | Calendar, Feed, Finances, Profile tabs |
| Community header | Name, icon, dropdown indicator |
| Community switcher | Bottom sheet with community list |
| No community state | Prompt to create or join |

#### Calendar Screens
| Task | Description |
|------|-------------|
| Month view | Calendar grid with event dots |
| List view | Chronological event list |
| View toggle | Switch between month/list |
| Event detail | Full event info, RSVP section |
| Create event | Form with all fields |
| Edit event | Reuse create form |
| RSVP buttons | Yes/No/Maybe selection |
| Family RSVP | Select family members, individual RSVPs |
| RSVP list | Who's going, maybe, not going |
| Empty state | No events illustration |

#### Feed Screens
| Task | Description |
|------|-------------|
| Feed list | Posts with pinned at top |
| Post card | Author, content, media, reactions, comments count |
| Post detail | Full post with comments |
| Create post | Text input, photo picker |
| Photo picker | Multiple image selection |
| Announcement style | Highlighted/pinned appearance |
| Poll display | Options, vote buttons, results |
| Poll creation | Question, options input |
| Reactions | Picker with emoji options |
| Comments | List with reply input |
| Empty state | No posts illustration |

#### Finances Screens
| Task | Description |
|------|-------------|
| Balance overview | Summary card, net owed/owing |
| Transaction list | Recent expenses |
| Transaction detail | Full breakdown |
| Add expense | Amount, description, payer |
| Receipt photo | Camera/library picker |
| Split selector | Member list with checkboxes |
| Custom split | Per-member amount input |
| Settle up | List of who you owe, Venmo button |
| Dues overview | Admin setup, member status |
| Dues detail | Who's paid tracker |
| Empty state | All settled illustration |

#### Profile & Settings Screens
| Task | Description |
|------|-------------|
| Profile overview | Avatar, name, communities list |
| Edit profile | Name, avatar picker |
| Family members | List of managed profiles |
| Add/edit family member | Name, avatar |
| Community settings | Info, preferences |
| Members list | All members with roles |
| Member detail | Profile, role, actions |
| Invite members | Code, QR, share options |
| Notification settings | Toggles per type |
| App settings | Theme, about, logout |

#### Shared Components
| Task | Description |
|------|-------------|
| Loading spinner | Consistent loading indicator |
| Loading skeleton | Content placeholders |
| Error view | Message with retry button |
| Empty state template | Illustration + message + CTA |
| Pull to refresh | Refresh control |
| Offline banner | "You're offline" indicator |
| Avatar component | Image with fallback initials |
| Button styles | Primary, secondary, destructive |

### Exit Criteria
- [ ] Every screen from UX Flows doc exists
- [ ] All screens have working SwiftUI previews
- [ ] Navigation between all screens works
- [ ] Mock data displays correctly everywhere
- [ ] Empty, loading, error states implemented

---

## Phase 2: Backend Setup

### Objective
Set up backend infrastructure while UI mockups are complete and validated.

### Deliverables
- [ ] Vapor project deployed to Azure
- [ ] PostgreSQL database running
- [ ] Authentication working end-to-end
- [ ] Core API endpoints functional

### Tasks

#### Vapor Project
| Task | Description |
|------|-------------|
| Create Vapor project | `vapor new OrbitCoveAPI` |
| Project structure | Controllers/, Models/, Services/ |
| Fluent + PostgreSQL | Database driver configured |
| Docker setup | Dockerfile for local + deployment |
| Environment config | Development, staging, production |
| Health endpoint | `GET /health` returns 200 |

#### Azure Infrastructure
| Task | Description |
|------|-------------|
| Resource group | `rg-orbitcove-staging` |
| App Service | Linux, Swift runtime |
| PostgreSQL | Flexible Server, Basic tier |
| Blob Storage | Container for media |
| Key Vault | Secrets storage |
| Notification Hub | Push notification setup |

#### CI/CD
| Task | Description |
|------|-------------|
| Backend workflow | Build, test, deploy on push |
| Branch protection | Require PR, passing tests |
| Staging deploy | Auto-deploy main to staging |

#### Authentication
| Task | Description |
|------|-------------|
| Azure AD B2C setup | Configure tenant |
| Sign in with Apple | B2C identity provider |
| Token exchange API | `POST /auth/apple` |
| JWT middleware | Validate on protected routes |
| Refresh token flow | `POST /auth/refresh` |

#### Database Models
| Task | Description |
|------|-------------|
| User model | Fluent model + migrations |
| Community model | With settings JSONB |
| Members model | Junction with roles |
| Invites model | Code generation |
| Event model | All calendar fields |
| Post model | All feed fields |
| Transaction model | All finance fields |

#### Core API Endpoints
| Task | Description |
|------|-------------|
| User endpoints | GET/PATCH/DELETE /me |
| Community endpoints | Full CRUD |
| Members endpoints | List, update role, remove |
| Invites endpoints | Create, join |

### Exit Criteria
- [ ] Backend deploys to Azure staging
- [ ] Can authenticate via Sign in with Apple
- [ ] Can create/join community via API
- [ ] Database migrations run successfully

---

## Phase 3: API Integration

### Objective
Connect iOS UI to real backend, replacing all mock services.

### Deliverables
- [ ] All features work with real API
- [ ] Data persists across sessions
- [ ] Push notifications functional
- [ ] Media upload working

### Tasks

#### Auth Integration
| Task | Description |
|------|-------------|
| Replace mock auth | Real Sign in with Apple flow |
| Token storage | Keychain integration |
| Refresh handling | Auto-refresh expired tokens |
| Logout flow | Clear tokens, reset state |

#### API Client
| Task | Description |
|------|-------------|
| Network service | URLSession with async/await |
| Request building | Headers, auth token injection |
| Response handling | Decode, error mapping |
| Retry logic | Transient failure handling |

#### Calendar API Integration
| Task | Description |
|------|-------------|
| Event endpoints | CRUD implementation |
| RSVP endpoints | Create/update RSVPs |
| Connect views | Replace mock with real data |
| Push notifications | Event reminders |

#### Feed API Integration
| Task | Description |
|------|-------------|
| Post endpoints | CRUD implementation |
| Comment endpoints | Add/delete comments |
| Reaction endpoints | Add/remove reactions |
| Poll endpoints | Create, vote, results |
| Connect views | Replace mock with real data |
| Push notifications | New posts, mentions |

#### Finances API Integration
| Task | Description |
|------|-------------|
| Transaction endpoints | CRUD implementation |
| Balance endpoint | Calculate balances |
| Dues endpoints | CRUD for dues |
| Connect views | Replace mock with real data |
| Push notifications | Payment reminders |

#### Media Upload
| Task | Description |
|------|-------------|
| Upload service | Multipart upload to Blob Storage |
| Avatar upload | Profile photos |
| Post photos | Multiple image upload |
| Receipt photos | Expense attachments |
| CDN integration | Serve via Front Door |

### Exit Criteria
- [ ] All mock services replaced with real API
- [ ] Data persists after app restart
- [ ] Push notifications arrive
- [ ] Photos upload and display correctly

---

## Phase 4: Polish & Offline

### Objective
Add offline support, polish the experience, and prepare for beta.

### Deliverables
- [ ] Full offline functionality
- [ ] Reliable sync
- [ ] Error handling
- [ ] Performance optimized
- [ ] Analytics in place

### Tasks

#### Offline & Sync
| Task | Description |
|------|-------------|
| Pending operations queue | SwiftData model for offline writes |
| Sync service | Upload pending, download changes |
| Conflict resolution | Last-write-wins implementation |
| Offline indicators | UI for pending/synced status |
| Background sync | iOS background refresh |
| Retry logic | Exponential backoff |

#### Cross-Pillar Integration
| Task | Description |
|------|-------------|
| Link expense to event | Optional association |
| Event auto-posts | Create feed post on event |
| Dues auto-post | Announce dues in feed |
| Deep link routing | Universal links |

#### Performance
| Task | Description |
|------|-------------|
| Image caching | NSCache implementation |
| Image compression | Resize before upload |
| Lazy loading | Load on scroll |
| Memory profiling | Instruments testing |

#### Error Handling
| Task | Description |
|------|-------------|
| Global error handler | Catch and display |
| Retry mechanisms | Auto-retry transient failures |
| Error reporting | Sentry integration |
| User-friendly messages | No technical jargon |

#### Analytics
| Task | Description |
|------|-------------|
| TelemetryDeck setup | Privacy-focused |
| Key events | Signup, create community, etc. |
| Crash reporting | Integrated tracking |

#### Final Polish
| Task | Description |
|------|-------------|
| Accessibility | VoiceOver, Dynamic Type |
| Edge cases | Member leaves, community deleted |
| Haptics | Feedback on actions |
| Animations | Smooth transitions |

### Exit Criteria
- [ ] App works fully offline
- [ ] Sync is reliable
- [ ] No critical bugs
- [ ] Performance targets met
- [ ] Analytics tracking key events

---

## Phase 5: Launch Prep

### Objective
Beta test, fix bugs, and ship to App Store.

### Deliverables
- [ ] Beta testing completed
- [ ] Critical bugs fixed
- [ ] App Store approved
- [ ] Live on App Store

### Tasks

#### Beta Testing
| Task | Description |
|------|-------------|
| Internal testing | Team dogfooding |
| TestFlight setup | Distribution config |
| Beta recruitment | 50+ testers |
| Feedback collection | In-app + survey |
| Bug triage | Prioritize issues |

#### Bug Fixes
| Task | Description |
|------|-------------|
| Critical fixes | Launch blockers |
| High priority | Significant UX issues |
| Medium priority | Can ship with |
| Low priority | Defer post-launch |

#### App Store Preparation
| Task | Description |
|------|-------------|
| App icon | All required sizes |
| Screenshots | iPhone 15 Pro, 6.7" |
| Description | Compelling copy |
| Keywords | ASO optimization |
| Privacy labels | Data disclosure |

#### Legal & Compliance
| Task | Description |
|------|-------------|
| Privacy policy | orbitcove.app/privacy |
| Terms of service | orbitcove.app/terms |
| GDPR compliance | Export, deletion |
| COPPA compliance | 13+ requirement |

#### Infrastructure
| Task | Description |
|------|-------------|
| Production environment | Azure production resources |
| Stripe integration | Subscription billing |
| Support email | support@orbitcove.app |
| FAQ/Help docs | Basic documentation |

#### App Store Submission
| Task | Description |
|------|-------------|
| App Store Connect | App record |
| Build upload | Production build |
| Submit for review | All metadata |
| Address rejection | If needed |
| Release | Go live |

### Exit Criteria
- [ ] 50+ beta testers completed
- [ ] No critical bugs
- [ ] App Store approved
- [ ] App live on App Store

---

## Critical Path

The critical path represents the longest sequence of dependent tasks. Delays here delay launch.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      CRITICAL PATH (UI-FIRST)                                │
└─────────────────────────────────────────────────────────────────────────────┘

iOS Setup ─► SwiftData Models ─► Mock Services ─► Navigation Shell
                                                         │
                                                         ▼
              ┌──────────────────────────────────────────────────────┐
              │                   UI MOCKUPS                          │
              │  Calendar ─► Feed ─► Finances ─► Profile ─► Polish   │
              └──────────────────────────────────────────────────────┘
                                                         │
                                                         ▼
Azure Setup ─► Vapor Project ─► Database Models ─► Auth (B2C + SIWA)
                                                         │
                                                         ▼
                                              API Integration ─► Offline Sync
                                                         │
                                                         ▼
                                              Beta Testing ─► Launch
```

### Critical Path Items

| Item | Why Critical |
|------|--------------|
| SwiftData models | Blocks all UI with mock data |
| Navigation shell | Blocks all screen development |
| All UI mockups | Must complete before backend integration |
| Azure AD B2C setup | Blocks real authentication |
| API integration | Blocks real data persistence |
| Offline sync | Required for real-world usage |
| Beta testing | Required for quality |

---

## Dependencies

### External Dependencies

| Dependency | Type | Risk | Mitigation |
|------------|------|------|------------|
| Apple Developer Account | Required | Low | Ensure enrollment current |
| Azure subscription | Required | Low | Budget allocated |
| Stripe account | Required | Low | Early setup |
| Domain (orbitcove.app) | Required | Low | Register early |
| Apple Sign-In approval | Required | Medium | Follow guidelines |
| App Store approval | Required | Medium | Follow guidelines |

### Technical Dependencies

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DEPENDENCY GRAPH                                      │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    Azure     │────►│   Database   │────►│   Models     │
│  Resources   │     │  (PostgreSQL)│     │  (Fluent)    │
└──────────────┘     └──────────────┘     └──────────────┘
                                                │
┌──────────────┐     ┌──────────────┐           │
│   Azure AD   │────►│     Auth     │◄──────────┤
│     B2C      │     │   Service    │           │
└──────────────┘     └──────────────┘           │
                            │                   │
                            ▼                   ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  iOS Auth    │────►│  API Client  │────►│   Features   │
│  (SIWA)      │     │  (Network)   │     │  (All)       │
└──────────────┘     └──────────────┘     └──────────────┘
                                                │
┌──────────────┐     ┌──────────────┐           │
│  Notif Hub   │────►│    Push      │◄──────────┤
│              │     │  Service     │           │
└──────────────┘     └──────────────┘           │
                                                │
┌──────────────┐     ┌──────────────┐           │
│    Blob      │────►│   Media      │◄──────────┘
│   Storage    │     │  Service     │
└──────────────┘     └──────────────┘
```

### Phase Dependencies

| Phase | Depends On |
|-------|------------|
| Phase 1: UI Mockups | Phase 0 complete (iOS setup) |
| Phase 2: Backend Setup | Can start in parallel with Phase 1 |
| Phase 3: API Integration | Phase 1 + Phase 2 both complete |
| Phase 4: Polish & Offline | Phase 3 complete |
| Phase 5: Launch Prep | Phase 4 complete |

**Key insight**: Backend work (Phase 2) can happen in parallel with UI mockups (Phase 1), but API integration (Phase 3) requires both to be complete.

---

## Resource Requirements

### Team Composition (Recommended)

| Role | Count | Responsibilities |
|------|-------|------------------|
| iOS Developer | 1-2 | SwiftUI app, offline sync |
| Backend Developer | 1 | Vapor API, Azure infrastructure |
| Designer | 0.5 | UI/UX, icons, App Store assets |
| QA | 0.5 | Testing, bug reporting |

**Minimum viable**: 1 full-stack Swift developer + part-time design help

### Skills Required

| Skill | Importance | Phase Needed |
|-------|------------|--------------|
| SwiftUI | Critical | All |
| SwiftData | High | Phase 1+ |
| Vapor/Fluent | Critical | All |
| PostgreSQL | High | Phase 0+ |
| Azure services | High | Phase 0+ |
| Sign in with Apple | High | Phase 1 |
| Push notifications | High | Phase 2 |
| Stripe integration | Medium | Phase 5-6 |

### Infrastructure Costs (Estimated Monthly)

| Service | Staging | Production |
|---------|---------|------------|
| Azure App Service (P1v3) | $50 | $150 |
| PostgreSQL (Burstable B2s) | $30 | $100 |
| Blob Storage (100GB) | $5 | $20 |
| Front Door (CDN) | $20 | $50 |
| Notification Hubs | $10 | $50 |
| **Total** | **~$115/mo** | **~$370/mo** |

### Tools & Services

| Tool | Purpose | Cost |
|------|---------|------|
| Apple Developer | App Store, certificates | $99/year |
| GitHub | Source control, CI/CD | Free (public) or $4/user/mo |
| Stripe | Payments | 2.9% + $0.30 per transaction |
| Sentry | Error tracking | Free tier sufficient |
| TelemetryDeck | Analytics | Free tier sufficient |
| Figma | Design | Free tier or $12/mo |

---

## Risk Buffer

### Recommended Buffer

Add **20-30% buffer** to all estimates for:
- Unforeseen technical challenges
- Azure/Apple service issues
- App Store review delays
- Bug fixes taking longer than expected
- Scope clarification needs

### Common Delays

| Risk | Typical Delay | Mitigation |
|------|---------------|------------|
| Azure AD B2C complexity | 1-2 weeks | Start early, use tutorials |
| Push notification debugging | 1 week | Test on real devices early |
| App Store rejection | 1-2 weeks | Follow guidelines, prepare appeal |
| Offline sync edge cases | 2 weeks | Test extensively, simple conflict resolution |
| Performance issues | 1 week | Profile early and often |

### Contingency Plans

| If... | Then... |
|-------|---------|
| Auth takes too long | Use simpler JWT-only approach, add B2C later |
| Vapor ecosystem issue | Fall back to .NET (last resort) |
| Push unreliable | Add in-app notification center, email fallback |
| App Store rejected | Address feedback, resubmit (budget 2 attempts) |
| Beta feedback overwhelming | Prioritize ruthlessly, defer non-critical |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 2026 | Claude | Initial draft |

---

*Next document: Risk Assessment*
