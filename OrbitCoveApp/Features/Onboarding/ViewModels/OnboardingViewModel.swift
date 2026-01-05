import SwiftUI

@Observable
final class OnboardingViewModel {
    var navigationPath = NavigationPath()
    var isLoading = false
    var error: Error?

    // Sign in
    var isSignedIn = false
    var currentUser: LocalUser?

    // Create community
    var communityName = ""
    var communityType: CommunityType = .family {
        didSet {
            // Update selected modules when community type changes
            selectedModules = Set(ModulePresets.defaultModules(for: communityType))
        }
    }
    var currentCommunity: LocalCommunity?

    // Module selection
    var selectedModules: Set<CommunityModule> = Set(CommunityModule.allCases)

    // Join community
    var inviteCode = ""

    // State
    var isComplete = false

    // MARK: - Actions

    func signInWithApple() async {
        isLoading = true
        error = nil

        do {
            try await Task.sleep(for: .milliseconds(500))
            currentUser = MockData.currentUser
            isSignedIn = true
            navigationPath.append(OnboardingStep.choice)
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func createCommunity() async {
        guard !communityName.isEmpty else { return }

        isLoading = true
        error = nil

        do {
            try await Task.sleep(for: .milliseconds(500))

            // Create community with type-appropriate default modules
            var settings = CommunitySettings.defaultSettings(for: communityType)
            settings.enabledModules = Array(selectedModules).sorted { $0.defaultOrder < $1.defaultOrder }

            currentCommunity = LocalCommunity(
                name: communityName,
                communityType: communityType,
                memberCount: 1,
                settings: settings
            )

            // Navigate to module selection
            navigationPath.append(OnboardingStep.selectModules)
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func confirmModules() {
        // Update community settings with final module selection
        currentCommunity?.settings.enabledModules = Array(selectedModules)
            .sorted { $0.defaultOrder < $1.defaultOrder }

        // Navigate to invite members
        navigationPath.append(OnboardingStep.inviteMembers)
    }

    func toggleModule(_ module: CommunityModule) {
        if selectedModules.contains(module) {
            // Prevent disabling all modules
            if selectedModules.count > 1 {
                selectedModules.remove(module)
            }
        } else {
            selectedModules.insert(module)
        }
    }

    func joinCommunity() async {
        guard !inviteCode.isEmpty else { return }

        isLoading = true
        error = nil

        do {
            try await Task.sleep(for: .milliseconds(500))

            if inviteCode.uppercased() == "ABC123" {
                currentCommunity = MockData.communities[1]
                isComplete = true
            } else {
                error = ServiceError.invalidInviteCode
            }
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func skipInvite() {
        isComplete = true
    }

    func finishOnboarding() {
        isComplete = true
    }
}
