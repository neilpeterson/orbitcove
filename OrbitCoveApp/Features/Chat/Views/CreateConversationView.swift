import SwiftUI

struct CreateConversationView: View {
    @Bindable var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMembers: Set<UUID> = []
    @State private var groupName = ""
    @State private var isCreating = false

    private var availableMembers: [(user: LocalUser, role: MemberRole)] {
        MockData.members.filter { $0.user.id != MockData.currentUser.id }
    }

    private var isGroup: Bool {
        selectedMembers.count > 1
    }

    private var canCreate: Bool {
        !selectedMembers.isEmpty
    }

    var body: some View {
        Form {
            // Group name section (only for groups)
            if isGroup {
                Section {
                    TextField("Group Name (optional)", text: $groupName)
                } header: {
                    Text("Group Name")
                }
            }

            // Member selection
            Section {
                ForEach(availableMembers, id: \.user.id) { member in
                    MemberSelectRow(
                        user: member.user,
                        isSelected: selectedMembers.contains(member.user.id)
                    ) {
                        if selectedMembers.contains(member.user.id) {
                            selectedMembers.remove(member.user.id)
                        } else {
                            selectedMembers.insert(member.user.id)
                        }
                    }
                }
            } header: {
                Text("Select Members")
            } footer: {
                if isGroup {
                    Text("Creating a group chat with \(selectedMembers.count) members")
                }
            }
        }
        .navigationTitle("New Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Create") {
                    createConversation()
                }
                .disabled(!canCreate || isCreating)
            }
        }
        .disabled(isCreating)
        .overlay {
            if isCreating {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
            }
        }
    }

    private func createConversation() {
        isCreating = true

        // Get selected users
        let selectedUsers = availableMembers
            .filter { selectedMembers.contains($0.user.id) }
            .map { $0.user }

        // Build participant lists (including current user)
        var participantIds = selectedUsers.map { $0.id }
        participantIds.insert(MockData.currentUser.id, at: 0)

        var participantNames = selectedUsers.map { $0.displayName }
        participantNames.insert(MockData.currentUser.displayName, at: 0)

        // Determine title
        let title: String? = isGroup ? (groupName.isEmpty ? nil : groupName) : nil

        Task {
            if let conversation = await viewModel.createConversation(
                title: title,
                participantIds: participantIds,
                participantNames: participantNames,
                isGroup: isGroup
            ) {
                viewModel.selectedConversation = conversation
            }

            isCreating = false
            dismiss()
        }
    }
}

struct MemberSelectRow: View {
    let user: LocalUser
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                AvatarView(
                    name: user.displayName,
                    imageUrl: user.avatarUrl,
                    size: 44
                )

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(user.displayName)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.primary)

                    Text(user.email)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Theme.Colors.primary : .secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        CreateConversationView(viewModel: ChatViewModel())
    }
}
