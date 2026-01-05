import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var showCommunitySwitcher = false

    var body: some View {
        @Bindable var appState = appState

        VStack(spacing: 0) {
            // Offline banner
            if !appState.isOnline {
                OfflineBanner()
            }

            // Main content with dynamic tabs
            TabView(selection: $appState.selectedTabId) {
                // Dynamic module tabs
                ForEach(appState.availableModules) { module in
                    NavigationStack {
                        moduleContent(for: module)
                            .toolbar {
                                ToolbarItem(placement: .principal) {
                                    CommunityHeaderButton {
                                        showCommunitySwitcher = true
                                    }
                                }
                            }
                    }
                    .tabItem {
                        Label(module.displayName, systemImage: module.icon)
                    }
                    .tag(module.id)
                }

                // Profile tab - always present, always last
                NavigationStack {
                    ProfileView()
                }
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(AppState.profileTabId)
            }
        }
        .sheet(isPresented: $showCommunitySwitcher) {
            CommunitySwitcherSheet()
                .presentationDetents([.medium, .large])
        }
        .onChange(of: appState.currentCommunity?.id) { _, _ in
            appState.validateSelectedTab()
        }
    }

    @ViewBuilder
    private func moduleContent(for module: CommunityModule) -> some View {
        switch module {
        case .dashboard:
            DashboardView()
        case .calendar:
            CalendarView()
        case .feed:
            FeedView()
        case .finances:
            FinancesView()
        }
    }
}

struct CommunityHeaderButton: View {
    @Environment(AppState.self) private var appState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.sm) {
                if let community = appState.currentCommunity {
                    CommunityAvatarView(
                        name: community.name,
                        iconUrl: community.iconUrl,
                        communityType: community.communityType,
                        size: 28
                    )

                    Text(community.name)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.primary)

                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct CommunitySwitcherSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var communities = MockData.communities
    @State private var showCreateCommunity = false
    @State private var showJoinCommunity = false

    var body: some View {
        NavigationStack {
            List {
                Section("Your Communities") {
                    ForEach(communities, id: \.id) { community in
                        CommunityRow(
                            community: community,
                            isSelected: appState.currentCommunity?.id == community.id
                        ) {
                            appState.currentCommunity = community
                            appState.validateSelectedTab()
                            dismiss()
                        }
                    }
                }

                Section {
                    Button {
                        showCreateCommunity = true
                    } label: {
                        Label("Create New Community", systemImage: "plus.circle")
                    }

                    Button {
                        showJoinCommunity = true
                    } label: {
                        Label("Join with Code", systemImage: "link.circle")
                    }
                }
            }
            .navigationTitle("Communities")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showCreateCommunity) {
            NavigationStack {
                CreateCommunitySheet()
            }
        }
        .sheet(isPresented: $showJoinCommunity) {
            NavigationStack {
                JoinCommunitySheet()
            }
        }
    }
}

struct CommunityRow: View {
    let community: LocalCommunity
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                CommunityAvatarView(
                    name: community.name,
                    iconUrl: community.iconUrl,
                    communityType: community.communityType,
                    size: 44
                )

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(community.name)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.primary)

                    Text("\(community.memberCount) members")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Theme.Colors.primary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let appState = AppState()
    appState.isAuthenticated = true
    appState.currentUser = MockData.currentUser
    appState.currentCommunity = MockData.currentCommunity

    return MainTabView()
        .environment(appState)
        .environment(\.services, ServiceContainer.shared)
}
