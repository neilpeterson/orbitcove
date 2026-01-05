import SwiftUI
import SwiftData

@main
struct OrbitCoveApp: App {
    @State private var appState = AppState()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LocalUser.self,
            LocalFamilyMember.self,
            LocalCommunity.self,
            LocalMembership.self,
            LocalEvent.self,
            LocalRSVP.self,
            LocalPost.self,
            LocalComment.self,
            LocalTransaction.self,
            LocalSplit.self,
            PendingOperation.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(\.services, ServiceContainer.shared)
        }
        .modelContainer(sharedModelContainer)
    }
}
