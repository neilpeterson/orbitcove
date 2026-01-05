import SwiftUI

struct CommunitySettingsView: View {
    let community: LocalCommunity
    @State private var showInviteMembers = false
    @State private var showLeaveConfirmation = false

    var body: some View {
        List {
            // Community info
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: Theme.Spacing.md) {
                        CommunityAvatarView(
                            name: community.name,
                            iconUrl: community.iconUrl,
                            communityType: community.communityType,
                            size: 80
                        )

                        Text(community.name)
                            .font(Theme.Typography.title3)
                            .fontWeight(.semibold)

                        Text(community.communityType.displayName)
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            // Members
            Section {
                NavigationLink {
                    MembersListView(community: community)
                } label: {
                    HStack {
                        Label("Members", systemImage: "person.3")

                        Spacer()

                        Text("\(community.memberCount)")
                            .foregroundStyle(.secondary)
                    }
                }

                Button {
                    showInviteMembers = true
                } label: {
                    Label("Invite Members", systemImage: "person.badge.plus")
                }
            }

            // Settings (Admin only)
            Section("Community Settings") {
                NavigationLink {
                    ManageModulesView(community: community)
                } label: {
                    HStack {
                        Label("Features", systemImage: "square.grid.2x2")

                        Spacer()

                        Text("\(community.settings.enabledModules.count) enabled")
                            .foregroundStyle(.secondary)
                    }
                }

                NavigationLink {
                    CommunityNotificationSettingsView(community: community)
                } label: {
                    Label("Notifications", systemImage: "bell")
                }

                NavigationLink {
                    CommunityPreferencesView(community: community)
                } label: {
                    Label("Preferences", systemImage: "gearshape")
                }
            }

            // Leave/Delete
            Section {
                Button(role: .destructive) {
                    showLeaveConfirmation = true
                } label: {
                    Label("Leave Community", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showInviteMembers) {
            NavigationStack {
                InviteMembersSheetView(community: community)
            }
        }
        .confirmationDialog("Leave \(community.name)?", isPresented: $showLeaveConfirmation) {
            Button("Leave", role: .destructive) {
                // Leave community
            }
        } message: {
            Text("You will no longer have access to this community's content. Your posts and contributions will remain.")
        }
    }
}

struct MembersListView: View {
    let community: LocalCommunity
    @State private var searchText = ""

    var body: some View {
        List {
            Section("Admins") {
                ForEach(MockData.members.filter { $0.role == .admin }, id: \.user.id) { member in
                    MemberRow(user: member.user, role: member.role)
                }
            }

            Section("Members") {
                ForEach(MockData.members.filter { $0.role == .member }, id: \.user.id) { member in
                    MemberRow(user: member.user, role: member.role)
                }
            }
        }
        .navigationTitle("Members (\(community.memberCount))")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search members")
    }
}

struct MemberRow: View {
    let user: LocalUser
    let role: MemberRole

    var body: some View {
        NavigationLink {
            MemberDetailView(user: user, role: role)
        } label: {
            HStack(spacing: Theme.Spacing.md) {
                AvatarView(name: user.displayName, imageUrl: user.avatarUrl, size: 44)

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(user.displayName)
                        .font(Theme.Typography.body)

                    Text(role.displayName)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }
}

struct MemberDetailView: View {
    let user: LocalUser
    let role: MemberRole
    @State private var showRemoveConfirmation = false
    @State private var showRoleChange = false

    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: Theme.Spacing.md) {
                        AvatarView(name: user.displayName, size: 80)

                        Text(user.displayName)
                            .font(Theme.Typography.title3)
                            .fontWeight(.semibold)

                        HStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: role == .admin ? "crown.fill" : "person.fill")
                            Text(role.displayName)
                        }
                        .font(Theme.Typography.caption)
                        .foregroundStyle(role == .admin ? Theme.Colors.warning : .secondary)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            Section("Actions") {
                Button {
                    showRoleChange = true
                } label: {
                    Label(
                        role == .admin ? "Remove Admin Role" : "Make Admin",
                        systemImage: "crown"
                    )
                }

                Button(role: .destructive) {
                    showRemoveConfirmation = true
                } label: {
                    Label("Remove from Community", systemImage: "person.badge.minus")
                }
            }
        }
        .navigationTitle("Member")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Remove \(user.displayName)?", isPresented: $showRemoveConfirmation) {
            Button("Remove", role: .destructive) {
                // Remove member
            }
        } message: {
            Text("They will no longer have access to the community. Their past posts and contributions will remain.")
        }
    }
}

struct InviteMembersSheetView: View {
    let community: LocalCommunity
    @Environment(\.dismiss) private var dismiss
    @State private var inviteCode = "ABC123"

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Text("Share this code with people you want to join \(community.name):")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.top, Theme.Spacing.lg)

            VStack(spacing: Theme.Spacing.md) {
                Text(inviteCode)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .tracking(4)

                Button {
                    UIPasteboard.general.string = inviteCode
                } label: {
                    Label("Copy Code", systemImage: "doc.on.doc")
                }
                .buttonStyle(.secondary)
            }
            .padding(Theme.Spacing.xl)
            .background(Theme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
            .padding(.horizontal, Theme.Spacing.lg)

            ShareLink(
                item: "Join \(community.name) on OrbitCove! Use code \(inviteCode) or tap: orbitcove.app/join/\(inviteCode)"
            ) {
                Label("Share Invite", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.primary)
            .padding(.horizontal, Theme.Spacing.lg)

            Spacer()
        }
        .navigationTitle("Invite Members")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}

struct CommunityNotificationSettingsView: View {
    let community: LocalCommunity
    @State private var newEvents = true
    @State private var eventReminders = true
    @State private var newPosts = true
    @State private var announcements = true
    @State private var comments = true
    @State private var financialUpdates = true
    @State private var quietHoursEnabled = false
    @State private var quietStart = DateComponents(hour: 22)
    @State private var quietEnd = DateComponents(hour: 7)

    var body: some View {
        Form {
            Section {
                Toggle("New Events", isOn: $newEvents)
                Toggle("Event Reminders", isOn: $eventReminders)
                Toggle("New Posts", isOn: $newPosts)

                HStack {
                    Toggle("Announcements", isOn: $announcements)
                    Text("(Cannot be disabled)")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.tertiary)
                }
                .disabled(true)

                Toggle("Comments & Mentions", isOn: $comments)
                Toggle("Financial Updates", isOn: $financialUpdates)
            }

            Section("Quiet Hours") {
                Toggle("Enable Quiet Hours", isOn: $quietHoursEnabled)

                if quietHoursEnabled {
                    DatePicker("Start", selection: .constant(Date()), displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: .constant(Date()), displayedComponents: .hourAndMinute)
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CommunityPreferencesView: View {
    let community: LocalCommunity
    @State private var allowMemberEvents = true
    @State private var allowMemberPosts = true

    var body: some View {
        Form {
            Section {
                Toggle("Allow members to create events", isOn: $allowMemberEvents)
                Toggle("Allow members to create posts", isOn: $allowMemberPosts)
            } footer: {
                Text("Admins can always create events and posts")
            }
        }
        .navigationTitle("Preferences")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CommunitySettingsView(community: MockData.currentCommunity)
    }
}
