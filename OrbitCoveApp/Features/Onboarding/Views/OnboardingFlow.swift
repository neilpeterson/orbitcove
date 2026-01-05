import SwiftUI

struct OnboardingFlow: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            WelcomeView(viewModel: viewModel)
                .navigationDestination(for: OnboardingStep.self) { step in
                    switch step {
                    case .choice:
                        ChoiceView(viewModel: viewModel)
                    case .createCommunity:
                        CreateCommunityView(viewModel: viewModel)
                    case .selectModules:
                        ModuleSelectionView(viewModel: viewModel)
                    case .joinCommunity:
                        JoinCommunityView(viewModel: viewModel)
                    case .inviteMembers:
                        InviteMembersView(viewModel: viewModel)
                    }
                }
        }
        .onChange(of: viewModel.isComplete) { _, isComplete in
            if isComplete {
                appState.isAuthenticated = true
                appState.currentUser = viewModel.currentUser
                appState.currentCommunity = viewModel.currentCommunity
            }
        }
    }
}

enum OnboardingStep: Hashable {
    case choice
    case createCommunity
    case selectModules
    case joinCommunity
    case inviteMembers
}

#Preview {
    OnboardingFlow()
        .environment(AppState())
        .environment(\.services, ServiceContainer.shared)
}
