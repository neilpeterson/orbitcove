# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OrbitCove is a privacy-first, all-in-one community platform for iOS. It enables groups (families, sports teams, clubs) to create private digital spaces with integrated organizational tools.

**Current Status**: Phase 1 complete. iOS app with full UI mockups using mock data. Backend not yet started.

## Technology Stack

| Component | Technology |
|-----------|------------|
| iOS App | SwiftUI, SwiftData, iOS 17+ |
| Backend | Swift (Vapor) on Azure App Service |
| Database | Azure Database for PostgreSQL |
| Storage | Azure Blob Storage + Front Door CDN |
| Auth | Azure AD B2C with Sign in with Apple |
| Push | Azure Notification Hubs → APNs |

## Build Commands

### iOS App
```bash
xcodebuild -scheme OrbitCoveApp -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild test -scheme OrbitCoveApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Vapor Backend
```bash
swift build
swift test
swift run
```

### Linting
```bash
swiftlint
swiftlint --fix
```

## Architecture Decisions

- **MVP Pillars**: Calendar, Social Feed, Shared Finances (Password vault and Photos deferred to v2.0)
- **Encryption**: TLS + Azure at-rest for MVP; full E2E encryption in v1.1
- **Offline Strategy**: Full offline writes with sync queue (not read-only cache)
- **Payments**: Stripe web checkout for subscriptions (avoids 30% Apple fee)
- **Multi-tenancy**: Shared database with Row-Level Security per community
- **Architecture Pattern**: MVVM with Services for iOS; Controller-Service-Repository for Vapor

## Project Structure

```
OrbitCove/
├── OrbitCoveApp/              # iOS SwiftUI app
│   ├── App/                   # App entry, delegates, main tab view
│   ├── Core/
│   │   ├── Modules/           # Community module system
│   │   └── Services/          # Service container, mock services
│   ├── Features/              # Feature modules
│   │   ├── Calendar/          # Calendar, events, RSVP
│   │   ├── Dashboard/         # Home dashboard
│   │   ├── Feed/              # Social feed, posts, comments
│   │   ├── Finances/          # Expenses, dues, settle up
│   │   ├── Onboarding/        # Welcome, create/join community
│   │   └── Profile/           # User profile, settings
│   ├── Shared/
│   │   ├── Components/        # Reusable UI components
│   │   ├── Extensions/        # Date, View extensions
│   │   ├── Models/            # Local data models
│   │   └── Theme/             # Design system (colors, fonts, spacing)
│   └── Resources/             # Assets, icons
├── OrbitCoveApp.xcodeproj/    # Xcode project
├── OrbitCoveAPI/              # Vapor backend (not yet created)
└── docs/                      # Planning documents
```

## Documentation

All planning documents are in `/docs/`:
- `01-PRD.md` - Product requirements, features, user stories
- `02-Technical-Architecture.md` - System design, API structure, security
- `03-Data-Model-Schema.md` - PostgreSQL schema, SwiftData models
- `04-UX-Flows.md` - Screen flows, wireframes, interaction patterns
- `05-Information-Architecture.md` - Content hierarchy, navigation, deep linking

## Key Domain Concepts

- **Community**: The primary container. All content belongs to a community
- **Member**: User's membership in a community with role (admin/member)
- **Family Member**: Parent-managed profile for children (no separate login)
- **Pillar**: One of the three feature areas (Calendar, Feed, Finances)

## Code Style

- Swift: Follow Swift API Design Guidelines
- Use `async/await` for all asynchronous code
- SwiftUI views should be small and composable
- ViewModels are `@Observable` classes (iOS 17+)
- Use dependency injection via environment for services
