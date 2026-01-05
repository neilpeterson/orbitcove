import SwiftUI

@Observable
final class AppState {
    var isAuthenticated: Bool = false
    var currentUser: LocalUser?
    var currentCommunity: LocalCommunity?
    var showCommunitySwitcher: Bool = false
    var isOnline: Bool = true
    var hasPendingSync: Bool = false

    /// Currently selected tab - either a module ID or "profile"
    var selectedTabId: String = CommunityModule.dashboard.id

    /// Special constant for the profile tab (not part of module system)
    static let profileTabId = "profile"

    /// Enabled modules for the current community, sorted by default order
    var availableModules: [CommunityModule] {
        guard let community = currentCommunity else {
            // Default to all modules when no community
            return CommunityModule.allCases.sorted { $0.defaultOrder < $1.defaultOrder }
        }
        return community.settings.enabledModules.sorted { $0.defaultOrder < $1.defaultOrder }
    }

    /// Check if a specific module is enabled
    func isModuleEnabled(_ module: CommunityModule) -> Bool {
        availableModules.contains(module)
    }

    /// Validate and reset selected tab if needed (e.g., when switching communities)
    func validateSelectedTab() {
        // Profile is always valid
        if selectedTabId == Self.profileTabId {
            return
        }

        // Check if selected module is still available
        let isValid = availableModules.contains { $0.id == selectedTabId }
        if !isValid {
            // Reset to first available module or dashboard
            selectedTabId = availableModules.first?.id ?? CommunityModule.dashboard.id
        }
    }

    func signOut() {
        isAuthenticated = false
        currentUser = nil
        currentCommunity = nil
        selectedTabId = CommunityModule.dashboard.id
    }
}
