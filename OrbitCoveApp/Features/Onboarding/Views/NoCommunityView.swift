import SwiftUI

struct NoCommunityView: View {
    @Environment(AppState.self) private var appState
    @State private var showCreateCommunity = false
    @State private var showJoinCommunity = false

    var body: some View {
        VStack(spacing: Theme.Spacing.xxl) {
            Spacer()

            // Icon and text
            VStack(spacing: Theme.Spacing.lg) {
                Image(systemName: "person.3")
                    .font(.system(size: 60))
                    .foregroundStyle(.tertiary)

                Text("Welcome to OrbitCove!")
                    .font(Theme.Typography.title2)
                    .fontWeight(.bold)

                Text("Create a community for your family, team, or group, or join one you've been invited to.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
            }

            Spacer()

            // Action buttons
            VStack(spacing: Theme.Spacing.md) {
                Button("Create Community") {
                    showCreateCommunity = true
                }
                .buttonStyle(.primary)

                Button("Join with Code") {
                    showJoinCommunity = true
                }
                .buttonStyle(.secondary)
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.bottom, Theme.Spacing.xxl)
        }
        .background(Theme.Colors.background)
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

struct CreateCommunitySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var name = ""
    @State private var type: CommunityType = .family
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Community Name")
                    .font(Theme.Typography.headline)

                TextField("e.g., Johnson Family", text: $name)
                    .textFieldStyle(.plain)
                    .inputFieldStyle()
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("Type")
                    .font(Theme.Typography.headline)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
                    ForEach(CommunityType.allCases, id: \.self) { communityType in
                        CommunityTypeCard(type: communityType, isSelected: type == communityType) {
                            type = communityType
                        }
                    }
                }
            }

            Spacer()

            Button("Create") {
                isLoading = true
                Task {
                    try? await Task.sleep(for: .milliseconds(500))
                    appState.currentCommunity = LocalCommunity(
                        name: name,
                        communityType: type
                    )
                    dismiss()
                }
            }
            .buttonStyle(.primary)
            .disabled(name.isEmpty || isLoading)
        }
        .padding(Theme.Spacing.lg)
        .navigationTitle("Create Community")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}

struct JoinCommunitySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var code = ""
    @State private var isLoading = false
    @State private var error: Error?

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            VStack(spacing: Theme.Spacing.md) {
                Text("Enter invite code:")
                    .font(Theme.Typography.headline)

                TextField("ABC123", text: $code)
                    .textFieldStyle(.plain)
                    .font(.system(size: 24, weight: .medium, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .inputFieldStyle()
            }

            if let error {
                ErrorBanner(message: error.localizedDescription) {
                    self.error = nil
                }
            }

            Spacer()

            Button("Join") {
                isLoading = true
                Task {
                    try? await Task.sleep(for: .milliseconds(500))
                    if code.uppercased() == "ABC123" {
                        appState.currentCommunity = MockData.communities[1]
                        dismiss()
                    } else {
                        error = ServiceError.invalidInviteCode
                        isLoading = false
                    }
                }
            }
            .buttonStyle(.primary)
            .disabled(code.isEmpty || isLoading)
        }
        .padding(Theme.Spacing.lg)
        .navigationTitle("Join Community")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}

#Preview {
    NoCommunityView()
        .environment(AppState())
}
