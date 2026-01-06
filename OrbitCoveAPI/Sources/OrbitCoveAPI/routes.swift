import Fluent
import Vapor

/// Health check response
struct HealthResponse: Content {
    let status: String
    let database: String
    let timestamp: String
}

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    // Health check endpoint
    app.get("health") { req async throws -> Response in
        let timestamp = ISO8601DateFormatter().string(from: Date())
        var dbStatus = "disconnected"
        var isHealthy = false

        // Check database connectivity by querying the migrations table
        do {
            _ = try await User.query(on: req.db).count()
            dbStatus = "connected"
            isHealthy = true
        } catch {
            // If User table doesn't exist yet, try a simpler check
            // The connection itself failing means unhealthy
            if error.localizedDescription.contains("does not exist") {
                // Table doesn't exist but connection works
                dbStatus = "connected (migrations pending)"
                isHealthy = true
            } else {
                dbStatus = "error: \(error.localizedDescription)"
            }
        }

        let health = HealthResponse(
            status: isHealthy ? "healthy" : "unhealthy",
            database: dbStatus,
            timestamp: timestamp
        )

        let response = Response(status: isHealthy ? .ok : .serviceUnavailable)
        try response.content.encode(health)
        return response
    }

    // Liveness probe (simple check that app is running)
    app.get("health", "live") { req async -> HTTPStatus in
        .ok
    }

    // Readiness probe (checks if app can serve traffic)
    app.get("health", "ready") { req async throws -> HTTPStatus in
        do {
            _ = try await User.query(on: req.db).count()
            return .ok
        } catch {
            if error.localizedDescription.contains("does not exist") {
                return .ok // Connection works, just no migrations yet
            }
            return .serviceUnavailable
        }
    }

    // Register API controllers
    try app.register(collection: UserController())
    try app.register(collection: CommunityController())
}
