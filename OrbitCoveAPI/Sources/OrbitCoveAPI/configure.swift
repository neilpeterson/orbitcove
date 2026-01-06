import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // Database configuration
    let hostname = Environment.get("DATABASE_HOST") ?? "localhost"
    let port = Environment.get("DATABASE_PORT").flatMap(Int.init) ?? 5432
    let username = Environment.get("DATABASE_USERNAME") ?? "orbitcove"
    let password = Environment.get("DATABASE_PASSWORD") ?? "orbitcove"
    let database = Environment.get("DATABASE_NAME") ?? "orbitcove"

    let postgresConfig = SQLPostgresConfiguration(
        hostname: hostname,
        port: port,
        username: username,
        password: password,
        database: database,
        tls: .prefer(try .init(configuration: .clientDefault))
    )

    app.databases.use(.postgres(configuration: postgresConfig), as: .psql)

    // Register migrations
    app.migrations.add(CreateInitialSchema())

    // Run migrations
    try await app.autoMigrate()

    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // register routes
    try routes(app)
}
