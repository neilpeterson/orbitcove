import SwiftUI

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var isAllDay = false
    @State private var location = ""
    @State private var category: EventCategory = .other
    @State private var isLoading = false

    var body: some View {
        Form {
            Section {
                TextField("Event title", text: $title)

                DatePicker(
                    "Starts",
                    selection: $startDate,
                    displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                )

                DatePicker(
                    "Ends",
                    selection: $endDate,
                    in: startDate...,
                    displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                )

                Toggle("All Day", isOn: $isAllDay)
            }

            Section {
                Picker("Category", selection: $category) {
                    ForEach(EventCategory.allCases, id: \.self) { cat in
                        Label(cat.displayName, systemImage: cat.icon)
                            .tag(cat)
                    }
                }

                HStack {
                    Image(systemName: "mappin")
                        .foregroundStyle(.secondary)
                    TextField("Location (optional)", text: $location)
                }
            }

            Section("Description") {
                TextField("What should people know about this event?", text: $description, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section {
                Button {
                    // Add reminder
                } label: {
                    HStack {
                        Label("Reminder", systemImage: "bell")
                        Spacer()
                        Text("1 day before")
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Button {
                    // Add attachment
                } label: {
                    Label("Add Attachment", systemImage: "paperclip")
                }
            }
        }
        .navigationTitle("New Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Create") {
                    createEvent()
                }
                .disabled(title.isEmpty || isLoading)
            }
        }
    }

    private func createEvent() {
        isLoading = true
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        CreateEventView()
    }
}
