import SwiftUI

struct ManageModulesView: View {
    let community: LocalCommunity
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var enabledModules: Set<CommunityModule>
    @State private var hasChanges = false
    @State private var showSaveConfirmation = false

    init(community: LocalCommunity) {
        self.community = community
        _enabledModules = State(initialValue: Set(community.settings.enabledModules))
    }

    var body: some View {
        List {
            Section {
                ForEach(CommunityModule.allCases) { module in
                    ModuleSettingsRow(
                        module: module,
                        isEnabled: enabledModules.contains(module),
                        isOnlyEnabled: enabledModules.count == 1 && enabledModules.contains(module)
                    ) {
                        toggleModule(module)
                    }
                }
            } footer: {
                Text("At least one feature must be enabled. Changes will take effect immediately.")
            }

            Section {
                Button("Reset to Defaults") {
                    resetToDefaults()
                }
                .foregroundStyle(Theme.Colors.primary)
            } footer: {
                Text("Restore the default features for a \(community.communityType.displayName.lowercased()) community.")
            }
        }
        .navigationTitle("Features")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
                .disabled(!hasChanges)
                .fontWeight(hasChanges ? .semibold : .regular)
            }
        }
        .alert("Changes Saved", isPresented: $showSaveConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your feature preferences have been updated.")
        }
    }

    private func toggleModule(_ module: CommunityModule) {
        if enabledModules.contains(module) {
            // Prevent disabling all modules
            if enabledModules.count > 1 {
                enabledModules.remove(module)
                hasChanges = true
            }
        } else {
            enabledModules.insert(module)
            hasChanges = true
        }
    }

    private func resetToDefaults() {
        let defaults = ModulePresets.defaultModules(for: community.communityType)
        enabledModules = Set(defaults)
        hasChanges = true
    }

    private func saveChanges() {
        // Update community settings
        appState.currentCommunity?.settings.enabledModules = Array(enabledModules)
            .sorted { $0.defaultOrder < $1.defaultOrder }

        // Validate current tab selection
        appState.validateSelectedTab()

        hasChanges = false
        showSaveConfirmation = true
    }
}

struct ModuleSettingsRow: View {
    let module: CommunityModule
    let isEnabled: Bool
    let isOnlyEnabled: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: module.icon)
                .font(.title3)
                .foregroundStyle(Theme.Colors.primary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(module.displayName)
                    .font(Theme.Typography.body)

                Text(module.description)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
            .disabled(isOnlyEnabled)
        }
    }
}

#Preview {
    NavigationStack {
        ManageModulesView(community: MockData.currentCommunity)
    }
    .environment(AppState())
}
