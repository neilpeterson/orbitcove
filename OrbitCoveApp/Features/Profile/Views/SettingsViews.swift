import SwiftUI

struct NotificationSettingsView: View {
    @State private var pushEnabled = true
    @State private var emailEnabled = false

    var body: some View {
        Form {
            Section {
                Toggle("Push Notifications", isOn: $pushEnabled)
                Toggle("Email Notifications", isOn: $emailEnabled)
            }

            Section("Per Community") {
                ForEach(MockData.communities, id: \.id) { community in
                    NavigationLink {
                        CommunityNotificationSettingsView(community: community)
                    } label: {
                        HStack {
                            CommunityAvatarView(
                                name: community.name,
                                communityType: community.communityType,
                                size: 32
                            )
                            Text(community.name)
                        }
                    }
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AppearanceSettingsView: View {
    @State private var colorScheme: ColorSchemePreference = .system

    enum ColorSchemePreference: String, CaseIterable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
    }

    var body: some View {
        Form {
            Section {
                Picker("Appearance", selection: $colorScheme) {
                    ForEach(ColorSchemePreference.allCases, id: \.self) { scheme in
                        Text(scheme.rawValue).tag(scheme)
                    }
                }
                .pickerStyle(.inline)
            }

            Section {
                NavigationLink {
                    // App icon picker
                    Text("App Icon")
                } label: {
                    HStack {
                        Text("App Icon")
                        Spacer()
                        Text("Default")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacySettingsView: View {
    @State private var showReadReceipts = true

    var body: some View {
        Form {
            Section {
                Toggle("Show Read Receipts", isOn: $showReadReceipts)
            } footer: {
                Text("When enabled, others can see when you've viewed their posts")
            }

            Section("Your Data") {
                NavigationLink {
                    DataExportView()
                } label: {
                    Text("Export Your Data")
                }

                NavigationLink {
                    DeleteAccountView()
                } label: {
                    Text("Delete Account")
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DataExportView: View {
    @State private var isExporting = false

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()

            Image(systemName: "arrow.down.doc")
                .font(.system(size: 64))
                .foregroundStyle(Theme.Colors.primary)

            Text("Export Your Data")
                .font(Theme.Typography.title2)
                .fontWeight(.bold)

            Text("Download a copy of all your data including posts, events, transactions, and more.")
                .font(Theme.Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)

            Spacer()

            Button {
                isExporting = true
            } label: {
                if isExporting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Request Export")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.primary)
            .disabled(isExporting)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xl)
        }
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DeleteAccountView: View {
    @State private var confirmText = ""
    @State private var showConfirmation = false
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.red)

            Text("Delete Account")
                .font(Theme.Typography.title2)
                .fontWeight(.bold)

            Text("This action cannot be undone. All your data will be permanently deleted after a 7-day grace period.")
                .font(Theme.Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Type DELETE to confirm:")
                    .font(Theme.Typography.subheadline)

                TextField("DELETE", text: $confirmText)
                    .textFieldStyle(.plain)
                    .inputFieldStyle()
                    .textInputAutocapitalization(.characters)
            }
            .padding(.horizontal, Theme.Spacing.lg)

            Spacer()

            Button {
                showConfirmation = true
            } label: {
                Text("Delete My Account")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.destructive)
            .disabled(confirmText != "DELETE")
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xl)
        }
        .navigationTitle("Delete Account")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Are you sure?", isPresented: $showConfirmation) {
            Button("Delete Account", role: .destructive) {
                appState.signOut()
            }
        } message: {
            Text("Your account will be scheduled for deletion. You have 7 days to cancel this action by logging back in.")
        }
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Theme.Colors.primary)

                        Text("OrbitCove")
                            .font(Theme.Typography.title2)
                            .fontWeight(.bold)

                        Text("Version 1.0.0")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            Section {
                Link(destination: URL(string: "https://orbitcove.app/privacy")!) {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }

                Link(destination: URL(string: "https://orbitcove.app/terms")!) {
                    Label("Terms of Service", systemImage: "doc.text")
                }

                Link(destination: URL(string: "https://orbitcove.app/help")!) {
                    Label("Help & Support", systemImage: "questionmark.circle")
                }
            }

            Section {
                Link(destination: URL(string: "https://twitter.com/orbitcoveapp")!) {
                    Label("Follow us on Twitter", systemImage: "at")
                }

                Button {
                    // Rate app
                } label: {
                    Label("Rate OrbitCove", systemImage: "star")
                }
            }

            Section {
                HStack {
                    Text("Made with ❤️ in San Francisco")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
