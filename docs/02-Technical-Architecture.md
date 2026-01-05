# OrbitCove - Technical Architecture Document

**Version**: 1.0 Draft
**Last Updated**: January 2026
**Status**: Review

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Technology Stack](#technology-stack)
3. [System Components](#system-components)
4. [Security Architecture](#security-architecture)
5. [Data Flow](#data-flow)
6. [API Design](#api-design)
7. [Infrastructure & Deployment](#infrastructure--deployment)
8. [Third-Party Integrations](#third-party-integrations)
9. [Scalability Strategy](#scalability-strategy)
10. [Offline & Sync Strategy](#offline--sync-strategy)
11. [Monitoring & Observability](#monitoring--observability)
12. [Technical Risks & Mitigations](#technical-risks--mitigations)

---

## Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CLIENT LAYER                                    │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                      iOS App (SwiftUI)                                 │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │  │
│  │  │  Calendar   │  │    Feed     │  │  Finances   │  │   Profile   │   │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘   │  │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │  │
│  │  │              Local Storage (SwiftData + Keychain)               │  │  │
│  │  └─────────────────────────────────────────────────────────────────┘  │  │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │  │
│  │  │              E2E Encryption Layer (Signal Protocol)             │  │  │
│  │  └─────────────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ HTTPS/WSS
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AZURE CLOUD                                     │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                     API Gateway (Azure API Management)                 │  │
│  │                    - Rate Limiting, Auth, Routing                      │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                      │                                       │
│         ┌────────────────────────────┼────────────────────────────┐         │
│         ▼                            ▼                            ▼         │
│  ┌─────────────┐            ┌─────────────┐            ┌─────────────┐      │
│  │   Auth      │            │   Core      │            │   Media     │      │
│  │  Service    │            │   API       │            │  Service    │      │
│  │  (Azure     │            │  (App       │            │  (Azure     │      │
│  │  AD B2C)    │            │  Service)   │            │  Functions) │      │
│  └─────────────┘            └─────────────┘            └─────────────┘      │
│                                      │                            │         │
│                                      ▼                            ▼         │
│                        ┌─────────────────────────┐    ┌─────────────┐       │
│                        │     Azure SQL           │    │ Blob Storage│       │
│                        │   (PostgreSQL)          │    │   + CDN     │       │
│                        └─────────────────────────┘    └─────────────┘       │
│                                                                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                      │
│  │   Redis     │    │  Service    │    │Notification │                      │
│  │   Cache     │    │    Bus      │    │    Hub      │                      │
│  └─────────────┘    └─────────────┘    └─────────────┘                      │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Architecture Principles

1. **Privacy by Design**: E2E encryption at the client; server never sees plaintext content
2. **Offline-First**: App is functional without connectivity; syncs when online
3. **API-First**: All functionality exposed via versioned REST APIs
4. **Event-Driven**: Async processing for non-critical paths (notifications, media processing)
5. **Cloud-Native**: Leverage Azure managed services to reduce operational burden

---

## Technology Stack

### Client (iOS)

| Component | Technology | Rationale |
|-----------|------------|-----------|
| UI Framework | SwiftUI | Modern, declarative, Apple's future direction |
| Minimum iOS | iOS 17+ | Access to latest SwiftUI features, SwiftData |
| Local Storage | SwiftData | Native persistence, iCloud sync potential |
| Secure Storage | Keychain | Encryption keys, auth tokens |
| Networking | URLSession + async/await | Native, no dependencies |
| E2E Encryption | libsignal-protocol-swift | Battle-tested, open source |
| Image Processing | Core Image, Vision | On-device, no data leaves device |
| Push Notifications | APNs (via Azure) | Native iOS push |
| Analytics | TelemetryDeck | Privacy-focused, GDPR compliant |

### Backend (Azure)

| Component | Technology | Rationale |
|-----------|------------|-----------|
| API Runtime | Azure App Service (Linux) | Managed, scalable, cost-effective |
| Language | Swift (Vapor) or C# (.NET 8) | Swift for code sharing; .NET for Azure integration |
| Database | Azure Database for PostgreSQL | Flexible Server, proven, great tooling |
| Cache | Azure Cache for Redis | Session state, rate limiting, hot data |
| File Storage | Azure Blob Storage | Cost-effective, durable |
| CDN | Azure Front Door | Global distribution, edge caching |
| Auth | Azure AD B2C | Sign in with Apple, managed auth |
| Push | Azure Notification Hubs | Multi-platform ready for future Android |
| Message Queue | Azure Service Bus | Async processing, guaranteed delivery |
| Functions | Azure Functions | Event processing, scheduled jobs |
| Key Management | Azure Key Vault | Secrets, certificates |
| Monitoring | Azure Monitor + App Insights | Logging, metrics, alerting |

### Recommended: Swift (Vapor) Backend

**Rationale for Vapor over .NET:**
- Code sharing between iOS and backend (models, validation logic)
- Single language for entire stack reduces context switching
- Vapor has mature Azure deployment support
- Strong async/await support mirrors iOS patterns

**Trade-offs:**
- Smaller talent pool than .NET
- Azure integration requires more manual setup
- Less mature than .NET ecosystem

**Decision**: Use **Vapor (Swift)** for backend. Benefits of code sharing and single-language stack outweigh Azure integration convenience.

---

## System Components

### iOS App Architecture

```
OrbitCove/
├── App/
│   ├── OrbitCoveApp.swift          # App entry point
│   └── AppDelegate.swift            # Push notifications, lifecycle
├── Core/
│   ├── Models/                      # Shared data models
│   ├── Services/
│   │   ├── AuthService.swift        # Authentication
│   │   ├── SyncService.swift        # Data synchronization
│   │   ├── CryptoService.swift      # E2E encryption
│   │   ├── NetworkService.swift     # API communication
│   │   └── NotificationService.swift
│   ├── Storage/
│   │   ├── LocalDatabase.swift      # SwiftData setup
│   │   └── KeychainManager.swift    # Secure storage
│   └── Utilities/
├── Features/
│   ├── Communities/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Components/
│   ├── Calendar/
│   ├── Feed/
│   ├── Finances/
│   ├── Profile/
│   └── Onboarding/
├── Shared/
│   ├── Components/                  # Reusable UI components
│   ├── Extensions/
│   └── Theme/                       # Colors, fonts, styling
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```

**Architecture Pattern**: MVVM with Services

- **Views**: SwiftUI views, purely declarative
- **ViewModels**: ObservableObject classes, business logic
- **Services**: Singleton/injected services for cross-cutting concerns
- **Models**: SwiftData @Model classes for persistence

### Backend Architecture

```
OrbitCoveAPI/
├── Sources/
│   └── App/
│       ├── configure.swift          # App configuration
│       ├── routes.swift             # Route registration
│       ├── Controllers/
│       │   ├── AuthController.swift
│       │   ├── CommunityController.swift
│       │   ├── EventController.swift
│       │   ├── PostController.swift
│       │   └── FinanceController.swift
│       ├── Models/
│       │   ├── User.swift
│       │   ├── Community.swift
│       │   ├── Event.swift
│       │   ├── Post.swift
│       │   └── Transaction.swift
│       ├── Migrations/
│       ├── Middleware/
│       │   ├── AuthMiddleware.swift
│       │   ├── RateLimitMiddleware.swift
│       │   └── LoggingMiddleware.swift
│       ├── Services/
│       │   ├── NotificationService.swift
│       │   ├── MediaService.swift
│       │   └── SubscriptionService.swift
│       └── Jobs/
│           ├── ReminderJob.swift
│           └── CleanupJob.swift
├── Tests/
└── Package.swift
```

---

## Security Architecture

### Encryption Strategy (Phased Approach)

> **Decision**: E2E encryption is phased. MVP (v1.0) uses TLS encryption only. Full E2E encryption will be implemented in v1.1.

#### Phase 1: MVP (v1.0) - Transport Encryption
- All data encrypted in transit via TLS 1.3
- Data encrypted at rest via Azure (server-side encryption)
- Server CAN read content (required for some features like search)
- Passwords/credentials feature deferred to v2.0 (requires E2E)

#### Phase 2: v1.1 - End-to-End Encryption
- Client-side encryption before upload
- Server stores only ciphertext
- Key management as described below

### End-to-End Encryption Architecture (v1.1)

The following architecture will be implemented in v1.1, using Signal Protocol.

#### Key Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         KEY HIERARCHY                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  User Identity Key (generated on device, never leaves)          │
│  └── Per-Device Key (for multi-device support)                  │
│      └── Community Key (shared symmetric key per community)     │
│          └── Content encrypted with community key               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

#### Encryption Flow

1. **User Registration**:
   - Device generates identity key pair (X25519)
   - Public key uploaded to server
   - Private key stored in iOS Keychain (Secure Enclave if available)

2. **Community Creation**:
   - Creator generates symmetric community key (AES-256)
   - Community key encrypted with creator's public key
   - Encrypted community key stored on server

3. **Member Joins**:
   - New member's public key retrieved from server
   - Admin's device encrypts community key with new member's public key
   - Encrypted key bundle sent to server for new member

4. **Content Encryption**:
   - All content (posts, events, transactions) encrypted with community key
   - Server stores only ciphertext
   - Decryption happens on-device

5. **Member Removal**:
   - Community key rotated
   - New key distributed to remaining members
   - Old content remains encrypted with old key (accessible to current members)

#### What the Server Sees

**v1.0 (MVP - TLS Only)**:
| Data Type | Server Visibility |
|-----------|------------------|
| All content | Visible (encrypted at rest by Azure) |

**v1.1 (E2E Encryption)**:
| Data Type | Server Visibility |
|-----------|------------------|
| User email/Apple ID | Visible (for auth) |
| User display name | Visible (for invites) |
| Community name | **Encrypted** |
| Community membership | Visible (for key distribution) |
| Events | **Encrypted** |
| Posts | **Encrypted** |
| Photos | **Encrypted** |
| Financial transactions | **Encrypted** |
| Encryption key bundles | Visible but encrypted per-user |

#### Key Management Challenges

1. **Key Rotation on Member Removal**: Must re-encrypt community key for all remaining members
2. **Multi-Device Support**: User's devices need secure key sync (via iCloud Keychain or manual)
3. **Account Recovery**: If user loses device and has no backup, they lose access (acceptable trade-off for security)
4. **Performance**: Decryption overhead on large content lists

#### Libraries

- **iOS**: `libsignal-protocol-swift` (Signal Protocol implementation)
- **Backend**: Server doesn't decrypt; only routes encrypted payloads

### Authentication

```
┌─────────────────────────────────────────────────────────────────┐
│                     AUTHENTICATION FLOW                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. User taps "Sign in with Apple"                              │
│  2. iOS presents Apple sign-in sheet                            │
│  3. Apple returns identity token + user info                    │
│  4. App sends identity token to backend                         │
│  5. Backend validates with Apple, creates/updates user          │
│  6. Backend returns OrbitCove JWT (access + refresh tokens)     │
│  7. App stores tokens in Keychain                               │
│  8. App generates encryption keys if new user                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Token Strategy**:
- Access token: 15 minutes, JWT, stateless validation
- Refresh token: 30 days, opaque, stored in database
- Revocation: Refresh tokens can be revoked immediately

### Data Protection

| Layer | Protection |
|-------|------------|
| In Transit | TLS 1.3, certificate pinning |
| At Rest (Client) | iOS Data Protection (Complete) |
| At Rest (Server) | Azure encryption + E2E encryption |
| Keychain | Secure Enclave when available |
| Database | Azure TDE + application-level E2E |
| Backups | Encrypted, excluded from iCloud backup by default |

---

## Data Flow

### Event Creation Flow

```
┌──────────┐         ┌──────────┐         ┌──────────┐         ┌──────────┐
│  User    │         │  iOS     │         │  Azure   │         │  Other   │
│          │         │  App     │         │  Backend │         │  Members │
└────┬─────┘         └────┬─────┘         └────┬─────┘         └────┬─────┘
     │                    │                    │                    │
     │ Create Event       │                    │                    │
     │───────────────────>│                    │                    │
     │                    │                    │                    │
     │                    │ Encrypt event      │                    │
     │                    │ with community key │                    │
     │                    │                    │                    │
     │                    │ POST /events       │                    │
     │                    │───────────────────>│                    │
     │                    │                    │                    │
     │                    │                    │ Store encrypted    │
     │                    │                    │ event              │
     │                    │                    │                    │
     │                    │                    │ Queue notification │
     │                    │                    │ job                │
     │                    │                    │                    │
     │                    │    201 Created     │                    │
     │                    │<───────────────────│                    │
     │                    │                    │                    │
     │   Event saved      │                    │                    │
     │   locally          │                    │                    │
     │<───────────────────│                    │                    │
     │                    │                    │                    │
     │                    │                    │ Push notification  │
     │                    │                    │───────────────────>│
     │                    │                    │ (encrypted payload)│
     │                    │                    │                    │
     │                    │                    │                    │ App fetches
     │                    │                    │                    │ & decrypts
```

### Sync Strategy

**Approach**: Timestamp-based incremental sync with conflict resolution

```swift
// Sync request
GET /communities/{id}/sync?since=2026-01-04T12:00:00Z

// Response
{
  "events": {
    "created": [...],
    "updated": [...],
    "deleted": ["id1", "id2"]
  },
  "posts": {...},
  "transactions": {...},
  "syncToken": "2026-01-04T12:05:00Z"
}
```

**Conflict Resolution**:
- Last-write-wins for simple fields
- Server timestamp is authoritative
- Client must merge before push if behind

---

## API Design

### API Versioning

- URL path versioning: `/api/v1/...`
- Breaking changes require new version
- Deprecation policy: 6 months notice, 12 months support

### Core Endpoints

#### Authentication
```
POST   /api/v1/auth/apple           # Sign in with Apple
POST   /api/v1/auth/refresh         # Refresh access token
DELETE /api/v1/auth/logout          # Revoke refresh token
```

#### Users
```
GET    /api/v1/me                   # Current user profile
PATCH  /api/v1/me                   # Update profile
DELETE /api/v1/me                   # Delete account
GET    /api/v1/me/communities       # List user's communities
POST   /api/v1/me/family-members    # Add managed family member
```

#### Communities
```
POST   /api/v1/communities                      # Create community
GET    /api/v1/communities/{id}                 # Get community
PATCH  /api/v1/communities/{id}                 # Update community
DELETE /api/v1/communities/{id}                 # Delete community
GET    /api/v1/communities/{id}/members         # List members
POST   /api/v1/communities/{id}/invites         # Create invite
POST   /api/v1/communities/{id}/join            # Join via code
DELETE /api/v1/communities/{id}/members/{uid}   # Remove member
PATCH  /api/v1/communities/{id}/members/{uid}   # Update role
GET    /api/v1/communities/{id}/sync            # Incremental sync
```

#### Events (Calendar)
```
GET    /api/v1/communities/{id}/events          # List events
POST   /api/v1/communities/{id}/events          # Create event
GET    /api/v1/communities/{id}/events/{eid}    # Get event
PATCH  /api/v1/communities/{id}/events/{eid}    # Update event
DELETE /api/v1/communities/{id}/events/{eid}    # Delete event
POST   /api/v1/communities/{id}/events/{eid}/rsvp  # RSVP
GET    /api/v1/communities/{id}/events/ics      # ICS calendar feed
```

#### Posts (Feed)
```
GET    /api/v1/communities/{id}/posts           # List posts (paginated)
POST   /api/v1/communities/{id}/posts           # Create post
GET    /api/v1/communities/{id}/posts/{pid}     # Get post with comments
PATCH  /api/v1/communities/{id}/posts/{pid}     # Update post
DELETE /api/v1/communities/{id}/posts/{pid}     # Delete post
POST   /api/v1/communities/{id}/posts/{pid}/reactions    # Add reaction
POST   /api/v1/communities/{id}/posts/{pid}/comments     # Add comment
```

#### Finances
```
GET    /api/v1/communities/{id}/transactions    # List transactions
POST   /api/v1/communities/{id}/transactions    # Create expense
GET    /api/v1/communities/{id}/balances        # Get all balances
POST   /api/v1/communities/{id}/settlements     # Record settlement
GET    /api/v1/communities/{id}/dues            # Get dues status
POST   /api/v1/communities/{id}/dues            # Set up dues
```

#### Media
```
POST   /api/v1/media/upload         # Get pre-signed upload URL
GET    /api/v1/media/{id}           # Get media (redirects to CDN)
```

### Request/Response Format

```json
// Standard success response
{
  "data": { ... },
  "meta": {
    "timestamp": "2026-01-04T12:00:00Z"
  }
}

// Standard error response
{
  "error": {
    "code": "COMMUNITY_NOT_FOUND",
    "message": "The requested community does not exist",
    "details": {}
  }
}

// Paginated response
{
  "data": [...],
  "pagination": {
    "total": 100,
    "page": 1,
    "perPage": 20,
    "hasMore": true
  }
}
```

---

## Infrastructure & Deployment

### Azure Resource Architecture

```
Resource Group: rg-orbitcove-prod
├── App Service Plan (Linux, P1v3)
│   └── App Service: api-orbitcove-prod
├── Azure Database for PostgreSQL (Flexible Server, Burstable B2s)
├── Azure Cache for Redis (Basic C1)
├── Storage Account: storbitcoveprod
│   ├── Container: media (photos, files)
│   └── Container: exports (data exports)
├── Azure Front Door (CDN + WAF)
├── Azure Notification Hubs Namespace
│   └── Hub: orbitcove-prod
├── Azure Service Bus Namespace
│   ├── Queue: notifications
│   ├── Queue: media-processing
│   └── Queue: reminders
├── Azure Key Vault: kv-orbitcove-prod
├── Application Insights: ai-orbitcove-prod
└── Azure AD B2C Tenant: orbitcoveb2c
```

### Environments

| Environment | Purpose | Scale |
|-------------|---------|-------|
| Development | Local development | Local containers |
| Staging | Pre-production testing | Minimal Azure (B-series) |
| Production | Live users | Production scale (P-series) |

### CI/CD Pipeline

```yaml
# GitHub Actions workflow (simplified)
name: Deploy

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: swift test

  deploy-staging:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Azure App Service (Staging)
        uses: azure/webapps-deploy@v2

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production  # Requires approval
    steps:
      - name: Deploy to Azure App Service (Production)
        uses: azure/webapps-deploy@v2
```

### Database Migrations

- Use Fluent (Vapor's ORM) migrations
- Migrations versioned and tracked in source control
- Zero-downtime migrations (add column, backfill, then enforce)

---

## Third-Party Integrations

### Required for MVP

| Service | Purpose | Integration Method |
|---------|---------|-------------------|
| **Apple Sign-In** | Authentication | Native iOS + SIWA token validation |
| **Apple Push Notification** | Push notifications | Via Azure Notification Hubs |
| **Venmo** | Payment deep links | URL scheme (no API needed) |
| **Apple Maps** | Location selection | MapKit |
| **Apple Calendar** | Event export | EventKit |

### Post-MVP Integrations

| Service | Purpose | Priority |
|---------|---------|----------|
| **Bitwarden** | Password vault | v2.0 |
| **Google Calendar** | Calendar sync | v1.5 |
| **Apple Pay** | In-app payments | v1.5 |
| **Stripe** | Subscription billing | v1.0 (admin portal) |

### Stripe Integration (Subscriptions)

For admin subscription payments, integrate Stripe:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   iOS App   │────>│   Backend   │────>│   Stripe    │
│             │     │             │     │             │
│ Upgrade tap │     │ Create      │     │ Checkout    │
│             │<────│ checkout    │<────│ session     │
│             │     │ session     │     │             │
│ Open Safari │     │             │     │             │
│ for Stripe  │     │ Webhook:    │     │             │
│ Checkout    │     │ subscription│     │             │
│             │     │ active      │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
```

*Note*: Using Stripe web checkout instead of in-app purchase to avoid 30% Apple fee for non-digital-goods subscriptions.

---

## Scalability Strategy

### Scaling Tiers

| Users | Communities | Infrastructure |
|-------|-------------|----------------|
| 0-10K | 0-5K | Single App Service (P1v3), Basic PostgreSQL |
| 10K-100K | 5K-50K | App Service scale-out (3 instances), General Purpose PostgreSQL |
| 100K-1M | 50K-500K | Multiple App Services, PostgreSQL read replicas, dedicated Redis |
| 1M+ | 500K+ | Microservices split, sharded databases, global distribution |

### Bottleneck Analysis

| Component | Bottleneck Risk | Mitigation |
|-----------|-----------------|------------|
| Database | High (writes) | Read replicas, connection pooling, query optimization |
| API | Medium | Horizontal scaling, caching, rate limiting |
| Media Storage | Low | Azure Blob is effectively unlimited |
| Push Notifications | Low | Notification Hubs scales automatically |
| Encryption/Decryption | Medium (client CPU) | Lazy decryption, caching decrypted content in memory |

### Caching Strategy

```
┌─────────────────────────────────────────────────────────────────┐
│                      CACHING LAYERS                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  L1: In-App Memory Cache (NSCache)                              │
│      - Decrypted content                                         │
│      - User profiles                                             │
│      - TTL: Session duration                                     │
│                                                                  │
│  L2: SwiftData Local Database                                   │
│      - All synced content (encrypted at rest)                   │
│      - TTL: Until sync updates                                  │
│                                                                  │
│  L3: Redis (Server)                                              │
│      - Session data                                              │
│      - Rate limit counters                                       │
│      - Hot community metadata                                    │
│      - TTL: 15 minutes - 1 hour                                 │
│                                                                  │
│  L4: Azure Front Door (CDN)                                     │
│      - Static assets                                             │
│      - Media files (with signed URLs)                           │
│      - TTL: 1 hour - 24 hours                                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Offline & Sync Strategy

### Offline Capabilities

| Feature | Offline Capability |
|---------|-------------------|
| View feed | Full (cached posts) |
| View calendar | Full (cached events) |
| View balances | Full (cached) |
| Create post | Queue for sync |
| Create event | Queue for sync |
| Add expense | Queue for sync |
| RSVP | Queue for sync |
| Upload photo | Queue for sync (when online) |

### Sync Architecture

**Decision**: Offline writes that sync (not read-only cache)

```swift
// Pending operation queue (SwiftData)
@Model
class PendingOperation {
    var id: UUID
    var type: OperationType  // .createPost, .updateEvent, etc.
    var payload: Data        // Encrypted operation data
    var createdAt: Date
    var retryCount: Int
    var status: SyncStatus   // .pending, .syncing, .failed
}
```

**Sync Flow**:
1. User performs action offline
2. Action saved locally + added to pending queue
3. When online, background task processes queue
4. Server returns authoritative timestamp
5. Local data updated with server response
6. Conflicts resolved (last-write-wins for most cases)

**Conflict Scenarios**:
- Two users edit same event: Last write wins, both see final version
- User deletes post another user is commenting on: Delete wins, comment discarded
- RSVP while event deleted: RSVP discarded, user notified

---

## Monitoring & Observability

### Logging Strategy

| Level | Usage | Example |
|-------|-------|---------|
| Error | Unexpected failures | Database connection failed |
| Warn | Recoverable issues | Rate limit approached |
| Info | Business events | User created community |
| Debug | Development troubleshooting | Request/response details |

**Privacy Note**: Logs must NEVER contain encrypted content, PII beyond user IDs, or sensitive metadata.

### Key Metrics

**Business Metrics** (Application Insights custom events):
- `community.created`
- `event.created`
- `post.created`
- `transaction.created`
- `member.joined`
- `subscription.started`

**Technical Metrics** (Azure Monitor):
- API response times (p50, p95, p99)
- Error rates by endpoint
- Database query performance
- Cache hit rates
- Push notification delivery rates

### Alerting

| Condition | Severity | Action |
|-----------|----------|--------|
| API error rate > 5% | Critical | Page on-call |
| API p99 latency > 2s | Warning | Slack notification |
| Database CPU > 80% | Warning | Slack notification |
| Failed push > 10% | Warning | Investigate |
| Zero signups in 24h | Info | Review (could be normal) |

---

## Technical Risks & Mitigations

### High Risk

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| ~~E2E encryption complexity delays MVP~~ | ~~Schedule~~ | ~~High~~ | **RESOLVED: Phased approach adopted. MVP launches with TLS encryption only; E2E added in v1.1** |
| Key management errors cause data loss (v1.1) | Catastrophic | Medium | Extensive testing, key backup to iCloud Keychain, gradual rollout |
| Vapor/Swift backend lacks needed library | Schedule | Medium | Identify all dependencies upfront; have .NET fallback plan |

### Medium Risk

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Sync conflicts cause data inconsistency | User trust | Medium | Comprehensive conflict resolution, optimistic UI with rollback |
| Push notification reliability | Engagement | Medium | Fallback to in-app badge, email digest option |
| Azure cost overruns | Budget | Medium | Set up cost alerts, use reserved instances, optimize early |

### Low Risk

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Apple rejects app | Schedule | Low | Follow guidelines, no IAP workarounds visible |
| Stripe subscription issues | Revenue | Low | Handle webhook failures gracefully, manual override capability |

---

## Technical Decisions Summary

| Decision | Choice | Rationale |
|----------|--------|-----------|
| iOS Framework | SwiftUI | Modern, Apple's direction |
| Min iOS Version | iOS 17 | SwiftData, latest SwiftUI |
| Backend Language | Swift (Vapor) | Code sharing, single language |
| Database | PostgreSQL (Azure) | Proven, flexible |
| Encryption (MVP) | TLS + Azure at-rest | Faster MVP, E2E in v1.1 |
| E2E Encryption (v1.1) | Signal Protocol | Battle-tested, open source |
| Auth Provider | Azure AD B2C | Managed, Sign in with Apple |
| Push Notifications | Azure Notification Hubs | Managed, multi-platform ready |
| CDN | Azure Front Door | Integrated, global |
| Offline Sync | Offline writes with queue | Better UX for teams in-field |
| Payments | Stripe (web checkout) | Avoid 30% Apple fee |

---

## Next Steps

1. **Validate E2E encryption approach** with prototype
2. **Finalize database schema** (next document)
3. **Prototype Vapor + Azure deployment**
4. **Define iOS project structure** and coding standards

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 2026 | Claude | Initial draft |

---

*This document should be reviewed by security specialists before implementation, particularly the E2E encryption architecture.*
