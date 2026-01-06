# OrbitCove API - Development Guide

## Prerequisites

- macOS 13+ (Ventura or later)
- Xcode 15+ (for Swift 5.9+)
- Docker Desktop (for PostgreSQL)
- Homebrew (optional, for native PostgreSQL)

## Quick Start

### 1. Start the Database

**Option A: Docker (Recommended)**
```bash
cd OrbitCoveAPI
docker compose up db -d
```

**Option B: Native PostgreSQL**
```bash
brew install postgresql@16
brew services start postgresql@16
createdb orbitcove
createuser -s orbitcove
```

### 2. Run the API

```bash
swift run
```

The server starts at `http://localhost:8080`

### 3. Verify It Works

```bash
curl http://localhost:8080
# Returns: It works!

curl http://localhost:8080/hello
# Returns: Hello, world!
```

---

## Development Workflow

### Building

```bash
# Debug build
swift build

# Release build
swift build -c release

# Clean build
swift package clean
swift build
```

### Running

```bash
# Run in development mode (default)
swift run

# Run with environment variables
DATABASE_HOST=localhost DATABASE_PORT=5432 swift run

# Run in production mode
swift run OrbitCoveAPI serve --env production
```

### Testing

```bash
# Run all tests
swift test

# Run specific test
swift test --filter TestClassName

# Run with verbose output
swift test --verbose
```

---

## Database Management

### Connection Details (Local)

| Setting | Value |
|---------|-------|
| Host | localhost |
| Port | 5432 |
| Database | orbitcove |
| Username | orbitcove |
| Password | orbitcove |

### Environment Variables

```bash
export DATABASE_HOST=localhost
export DATABASE_PORT=5432
export DATABASE_USERNAME=orbitcove
export DATABASE_PASSWORD=orbitcove
export DATABASE_NAME=orbitcove
```

### Migrations

Migrations run automatically on startup via `app.autoMigrate()`.

**To run migrations manually:**
```bash
swift run OrbitCoveAPI migrate
```

**To revert last migration:**
```bash
swift run OrbitCoveAPI migrate --revert
```

**To revert all migrations:**
```bash
swift run OrbitCoveAPI migrate --revert --all
```

### Connecting to Database

```bash
# Via Docker
docker exec -it orbitcoveapi-db-1 psql -U orbitcove -d orbitcove

# Via native psql
psql -h localhost -U orbitcove -d orbitcove
```

### Useful SQL Commands

```sql
-- List all tables
\dt

-- Describe a table
\d users

-- Check migration status
SELECT * FROM _fluent_migrations;

-- Count records
SELECT COUNT(*) FROM users;

-- View table data
SELECT * FROM users LIMIT 10;
```

---

## Docker Commands

### Start Services

```bash
# Start database only (background)
docker compose up db -d

# Start everything (API + database)
docker compose up -d

# Start with logs visible
docker compose up
```

### Stop Services

```bash
# Stop all services
docker compose down

# Stop and remove volumes (deletes data!)
docker compose down -v
```

### View Logs

```bash
# All services
docker compose logs

# Database only
docker compose logs db

# Follow logs
docker compose logs -f
```

### Reset Database

```bash
# Stop and remove everything including data
docker compose down -v

# Start fresh
docker compose up db -d
swift run  # This will recreate tables
```

---

## API Testing with cURL

### Health Endpoints
```bash
# Basic check
curl http://localhost:8080

# Full health check (returns JSON with db status)
curl http://localhost:8080/health

# Liveness probe (is the app running?)
curl http://localhost:8080/health/live

# Readiness probe (can the app serve traffic?)
curl http://localhost:8080/health/ready
```

**Health response example:**
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2026-01-05T18:30:00Z"
}
```

### Create a User (example - requires endpoint implementation)
```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "appleId": "001234.abc123",
    "email": "test@example.com",
    "displayName": "Test User"
  }'
```

### Get Users (example - requires endpoint implementation)
```bash
curl http://localhost:8080/api/users
```

---

## Project Structure

```
OrbitCoveAPI/
├── Sources/OrbitCoveAPI/
│   ├── entrypoint.swift      # App entry point
│   ├── configure.swift       # Database & middleware setup
│   ├── routes.swift          # Route registration
│   ├── Models/               # Fluent models (17 total)
│   │   ├── User.swift
│   │   ├── Community.swift
│   │   ├── Event.swift
│   │   ├── Post.swift
│   │   └── ...
│   ├── Migrations/           # Database migrations
│   │   └── CreateInitialSchema.swift
│   ├── Controllers/          # Route handlers (TODO)
│   └── DTOs/                 # Data transfer objects (TODO)
├── Tests/OrbitCoveAPITests/  # Unit tests
├── Package.swift             # Dependencies
├── docker-compose.yml        # Docker services
└── Dockerfile                # Production build
```

---

## Common Issues & Solutions

### Port Already in Use

```bash
# Find what's using port 8080
lsof -i :8080

# Kill the process
kill -9 <PID>
```

### Database Connection Failed

1. Check if PostgreSQL is running:
   ```bash
   docker compose ps
   # or
   brew services list
   ```

2. Check connection details match environment variables

3. Try connecting directly:
   ```bash
   psql -h localhost -U orbitcove -d orbitcove
   ```

### Migration Errors

1. Check migration status:
   ```sql
   SELECT * FROM _fluent_migrations;
   ```

2. If stuck, reset database:
   ```bash
   docker compose down -v
   docker compose up db -d
   swift run
   ```

### Build Errors After Pulling Changes

```bash
swift package clean
swift package resolve
swift build
```

---

## Environment Configurations

### Development (default)
- Debug logging enabled
- Auto-migrations on startup
- Local PostgreSQL

### Production
- Minimal logging
- Migrations must be run explicitly
- Uses environment variables for all config

```bash
# Run in production mode
swift run OrbitCoveAPI serve \
  --env production \
  --hostname 0.0.0.0 \
  --port 8080
```

---

## Adding New Features

### 1. Create a Model

```swift
// Sources/OrbitCoveAPI/Models/NewModel.swift
import Fluent
import Foundation

final class NewModel: Model, @unchecked Sendable {
    static let schema = "new_models"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    init() {}
}
```

### 2. Create a Migration

```swift
// Sources/OrbitCoveAPI/Migrations/CreateNewModel.swift
import Fluent

struct CreateNewModel: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("new_models")
            .id()
            .field("name", .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("new_models").delete()
    }
}
```

### 3. Register Migration

```swift
// In configure.swift
app.migrations.add(CreateNewModel())
```

### 4. Create a Controller

```swift
// Sources/OrbitCoveAPI/Controllers/NewModelController.swift
import Vapor
import Fluent

struct NewModelController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let models = routes.grouped("api", "new-models")
        models.get(use: index)
        models.post(use: create)
    }

    func index(req: Request) async throws -> [NewModel] {
        try await NewModel.query(on: req.db).all()
    }

    func create(req: Request) async throws -> NewModel {
        let model = try req.content.decode(NewModel.self)
        try await model.save(on: req.db)
        return model
    }
}
```

### 5. Register Routes

```swift
// In routes.swift
try app.register(collection: NewModelController())
```

---

## Database Schema

### Tables Created

| Table | Description |
|-------|-------------|
| users | Authenticated user accounts |
| family_members | Parent-managed child profiles |
| communities | Private group spaces |
| members | User-community membership |
| invites | Pending community invitations |
| events | Calendar events |
| rsvps | Event responses |
| posts | Social feed posts |
| reactions | Post reactions |
| comments | Post comments |
| poll_votes | Poll responses |
| transactions | Financial transactions |
| splits | Transaction splits |
| dues | Recurring dues setup |
| dues_payments | Dues payment records |
| media | Uploaded media files |
| notifications | User notifications |
| audit_log | Action audit trail |
| refresh_tokens | Auth refresh tokens |

### Entity Relationships

```
users
  ├── family_members (1:N)
  ├── memberships (1:N) → communities
  ├── events_created (1:N)
  ├── posts_authored (1:N)
  └── transactions_created (1:N)

communities
  ├── members (1:N)
  ├── events (1:N)
  ├── posts (1:N)
  ├── transactions (1:N)
  └── invites (1:N)

events
  └── rsvps (1:N)

posts
  ├── reactions (1:N)
  ├── comments (1:N)
  └── poll_votes (1:N)

transactions
  └── splits (1:N)

dues
  └── payments (1:N)
```

---

## Useful Links

- [Vapor Documentation](https://docs.vapor.codes)
- [Fluent Documentation](https://docs.vapor.codes/fluent/overview/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Swift Package Manager](https://swift.org/package-manager/)
