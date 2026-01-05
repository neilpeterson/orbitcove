import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.isAuthenticated {
                if appState.currentCommunity != nil {
                    MainTabView()
                } else {
                    NoCommunityView()
                }
            } else {
                OnboardingFlow()
            }
        }
        .animation(.easeInOut, value: appState.isAuthenticated)
    }
}

#Preview {
    RootView()
        .environment(AppState())
        .environment(\.services, ServiceContainer.shared)
}
