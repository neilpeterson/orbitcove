import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var showEditProfile = false

    var body: some View {
        List {
            // User info section
            Section {
                HStack(spacing: Theme.Spacing.md) {
                    AvatarView(
                        name: appState.currentUser?.displayName ?? "User",
                        imageUrl: appState.currentUser?.avatarUrl,
                        size: 64
                    )

                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text(appState.currentUser?.displayName ?? "User")
                            .font(Theme.Typography.title3)
                            .fontWeight(.semibold)

                        Text(appState.currentUser?.email ?? "")
                            .font(Theme.Typography.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        showEditProfile = true
                    } label: {
                        Text("Edit")
                            .font(Theme.Typography.subheadline)
                    }
                }
                .padding(.vertical, Theme.Spacing.sm)
            }

            // Family members
            Section {
                NavigationLink {
                    FamilyMembersView()
                } label: {
                    HStack {
                        Image(systemName: "person.2")
                            .foregroundStyle(Theme.Colors.primary)

                        Text("Family Members")

                        Spacer()

                        Text("\(MockData.currentUserFamilyMembers.count)")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Communities
            Section("Your Communities") {
                ForEach(MockData.communities, id: \.id) { community in
                    NavigationLink {
                        CommunitySettingsView(community: community)
                    } label: {
                        HStack(spacing: Theme.Spacing.md) {
                            CommunityAvatarView(
                                name: community.name,
                                iconUrl: community.iconUrl,
                                communityType: community.communityType,
                                size: 40
                            )

                            VStack(alignment: .leading) {
                                Text(community.name)
                                    .font(Theme.Typography.body)

                                Text("\(community.memberCount) members")
                                    .font(Theme.Typography.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if appState.currentCommunity?.id == community.id {
                                Text("Active")
                                    .font(Theme.Typography.caption)
                                    .foregroundStyle(Theme.Colors.primary)
                            }
                        }
                    }
                }
            }

            // App Settings
            Section("Settings") {
                NavigationLink {
                    NotificationSettingsView()
                } label: {
                    Label("Notifications", systemImage: "bell")
                }

                NavigationLink {
                    AppearanceSettingsView()
                } label: {
                    Label("Appearance", systemImage: "paintbrush")
                }

                NavigationLink {
                    PrivacySettingsView()
                } label: {
                    Label("Privacy", systemImage: "lock")
                }

                NavigationLink {
                    AboutView()
                } label: {
                    Label("About", systemImage: "info.circle")
                }
            }

            // Account
            Section {
                Button(role: .destructive) {
                    appState.signOut()
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .navigationTitle("Profile")
        .sheet(isPresented: $showEditProfile) {
            NavigationStack {
                EditProfileView()
            }
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var displayName = MockData.currentUser.displayName
    @State private var isLoading = false

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: Theme.Spacing.md) {
                        AvatarView(name: displayName, size: 80)

                        Button("Change Photo") {
                            // Photo picker
                        }
                        .font(Theme.Typography.subheadline)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            Section("Name") {
                TextField("Display Name", text: $displayName)
            }

            Section {
                HStack {
                    Text("Email")
                    Spacer()
                    Text(MockData.currentUser.email)
                        .foregroundStyle(.secondary)
                }
            } footer: {
                Text("Email is managed through your Apple ID")
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    isLoading = true
                    Task {
                        try? await Task.sleep(for: .milliseconds(500))
                        dismiss()
                    }
                }
                .disabled(displayName.isEmpty || isLoading)
            }
        }
    }
}

struct FamilyMembersView: View {
    @State private var showAddMember = false

    var body: some View {
        List {
            Section {
                ForEach(MockData.currentUserFamilyMembers, id: \.id) { member in
                    NavigationLink {
                        EditFamilyMemberView(member: member)
                    } label: {
                        HStack(spacing: Theme.Spacing.md) {
                            AvatarView(name: member.name, size: 44)

                            Text(member.name)
                                .font(Theme.Typography.body)
                        }
                    }
                }
            } footer: {
                Text("Family members are profiles you manage. They can RSVP to events through your account but don't have their own login.")
            }
        }
        .navigationTitle("Family Members")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddMember = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddMember) {
            NavigationStack {
                AddFamilyMemberView()
            }
        }
    }
}

struct EditFamilyMemberView: View {
    let member: LocalFamilyMember
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var showDeleteConfirmation = false

    init(member: LocalFamilyMember) {
        self.member = member
        _name = State(initialValue: member.name)
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: Theme.Spacing.md) {
                        AvatarView(name: name, size: 80)

                        Button("Change Photo") {
                            // Photo picker
                        }
                        .font(Theme.Typography.subheadline)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            Section {
                TextField("Name", text: $name)
            }

            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Text("Remove Family Member")
                }
            }
        }
        .navigationTitle("Edit Family Member")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
        }
        .confirmationDialog("Remove \(member.name)?", isPresented: $showDeleteConfirmation) {
            Button("Remove", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("This will remove \(member.name) from your family members. Their past RSVPs will remain.")
        }
    }
}

struct AddFamilyMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
            } footer: {
                Text("Add a family member like a child or spouse who doesn't have their own account.")
            }
        }
        .navigationTitle("Add Family Member")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
        }
    }
}

#Preview {
    let appState = AppState()
    appState.currentUser = MockData.currentUser
    appState.currentCommunity = MockData.currentCommunity

    return NavigationStack {
        ProfileView()
    }
    .environment(appState)
}
