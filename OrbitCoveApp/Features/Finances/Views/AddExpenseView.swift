import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var description = ""
    @State private var amount = ""
    @State private var paidBy = MockData.currentUser
    @State private var category: ExpenseCategory = .other
    @State private var splitType: SplitType = .everyone
    @State private var selectedMembers: Set<UUID> = []
    @State private var showMemberPicker = false
    @State private var isLoading = false

    enum SplitType: String, CaseIterable {
        case everyone = "Everyone equally"
        case selectPeople = "Select people"
        case custom = "Custom amounts"
    }

    var body: some View {
        Form {
            Section {
                TextField("What was it for?", text: $description)

                HStack {
                    Text("$")
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                }
            }

            Section {
                Picker("Who paid?", selection: $paidBy) {
                    Text("Me (\(MockData.currentUser.displayName))")
                        .tag(MockData.currentUser)
                    ForEach(MockData.members.map { $0.user }.filter { $0.id != MockData.currentUser.id }, id: \.id) { user in
                        Text(user.displayName)
                            .tag(user)
                    }
                }
            }

            Section("Split between") {
                ForEach(SplitType.allCases, id: \.self) { type in
                    HStack {
                        Image(systemName: splitType == type ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(splitType == type ? Theme.Colors.primary : .secondary)

                        Text(type.rawValue)

                        Spacer()

                        if type == .everyone {
                            Text("(\(MockData.members.count) people)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        splitType = type
                        if type == .selectPeople {
                            showMemberPicker = true
                        }
                    }
                }

                if splitType == .selectPeople && !selectedMembers.isEmpty {
                    Text("\(selectedMembers.count) people selected")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Category") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: Theme.Spacing.md) {
                    ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                        CategoryButton(
                            category: cat,
                            isSelected: category == cat
                        ) {
                            category = cat
                        }
                    }
                }
            }

            Section {
                Button {
                    // Add receipt photo
                } label: {
                    Label("Add receipt photo", systemImage: "camera")
                }
            }
        }
        .navigationTitle("Add Expense")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveExpense()
                }
                .disabled(description.isEmpty || amount.isEmpty || isLoading)
            }
        }
        .sheet(isPresented: $showMemberPicker) {
            NavigationStack {
                MemberPickerView(selectedMembers: $selectedMembers)
            }
        }
    }

    private func saveExpense() {
        isLoading = true
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            dismiss()
        }
    }
}

struct CategoryButton: View {
    let category: ExpenseCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.xs) {
                Image(systemName: category.icon)
                    .font(.title2)

                Text(category.displayName)
                    .font(Theme.Typography.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.sm)
            .background(isSelected ? Theme.Colors.primary.opacity(0.1) : Theme.Colors.tertiaryBackground)
            .foregroundStyle(isSelected ? Theme.Colors.primary : .primary)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
        }
        .buttonStyle(.plain)
    }
}

struct MemberPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMembers: Set<UUID>
    @State private var selectAll = false

    var body: some View {
        List {
            Section {
                Toggle("Select all", isOn: $selectAll)
                    .onChange(of: selectAll) { _, newValue in
                        if newValue {
                            selectedMembers = Set(MockData.members.map { $0.user.id })
                        } else {
                            selectedMembers.removeAll()
                        }
                    }
            }

            Section {
                ForEach(MockData.members, id: \.user.id) { member in
                    HStack {
                        AvatarView(name: member.user.displayName, size: 36)

                        Text(member.user.displayName)

                        Spacer()

                        if selectedMembers.contains(member.user.id) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Theme.Colors.primary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedMembers.contains(member.user.id) {
                            selectedMembers.remove(member.user.id)
                        } else {
                            selectedMembers.insert(member.user.id)
                        }
                    }
                }
            }
        }
        .navigationTitle("Split Between")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddExpenseView()
    }
}
