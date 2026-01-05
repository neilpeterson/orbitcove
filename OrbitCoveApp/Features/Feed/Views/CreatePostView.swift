import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var content = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showPollCreator = false
    @State private var isAnnouncement = false
    @State private var isLoading = false
    @FocusState private var isContentFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    // Content input
                    TextField("What's on your mind?", text: $content, axis: .vertical)
                        .font(Theme.Typography.body)
                        .lineLimit(5...20)
                        .focused($isContentFocused)
                        .padding(Theme.Spacing.md)

                    // Selected photos preview
                    if !selectedPhotos.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Theme.Spacing.sm) {
                                ForEach(0..<selectedPhotos.count, id: \.self) { index in
                                    ZStack(alignment: .topTrailing) {
                                        Rectangle()
                                            .fill(Theme.Colors.tertiaryBackground)
                                            .frame(width: 100, height: 100)
                                            .overlay {
                                                Image(systemName: "photo")
                                                    .foregroundStyle(.tertiary)
                                            }
                                            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))

                                        Button {
                                            selectedPhotos.remove(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.white, .black.opacity(0.6))
                                        }
                                        .offset(x: 4, y: -4)
                                    }
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                        }
                    }
                }
            }

            Divider()

            // Action bar
            VStack(spacing: Theme.Spacing.sm) {
                HStack(spacing: Theme.Spacing.lg) {
                    PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 10) {
                        Image(systemName: "photo")
                            .font(.title3)
                    }

                    Button {
                        showPollCreator = true
                    } label: {
                        Image(systemName: "chart.bar")
                            .font(.title3)
                    }

                    // Announcement toggle (admin only)
                    Button {
                        isAnnouncement.toggle()
                    } label: {
                        Image(systemName: isAnnouncement ? "megaphone.fill" : "megaphone")
                            .font(.title3)
                            .foregroundStyle(isAnnouncement ? Theme.Colors.warning : .primary)
                    }

                    Button {
                        // Mention someone
                    } label: {
                        Image(systemName: "at")
                            .font(.title3)
                    }

                    Spacer()
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.sm)

                if isAnnouncement {
                    HStack {
                        Image(systemName: "info.circle")
                            .font(.caption)
                        Text("Announcements are pinned and can't be disabled by members")
                            .font(Theme.Typography.caption)
                    }
                    .foregroundStyle(Theme.Colors.warning)
                    .padding(.horizontal, Theme.Spacing.md)
                }
            }
            .padding(.bottom, Theme.Spacing.md)
            .background(Theme.Colors.secondaryBackground)
        }
        .navigationTitle("New Post")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Post") {
                    createPost()
                }
                .disabled(content.isEmpty || isLoading)
            }
        }
        .sheet(isPresented: $showPollCreator) {
            NavigationStack {
                CreatePollView()
            }
        }
        .onAppear {
            isContentFocused = true
        }
    }

    private func createPost() {
        isLoading = true
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            dismiss()
        }
    }
}

struct CreatePollView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var question = ""
    @State private var options: [String] = ["", ""]
    @State private var allowMultiple = false
    @State private var hasDeadline = false
    @State private var deadline = Date().addingTimeInterval(86400 * 7)

    var body: some View {
        Form {
            Section {
                TextField("What do you want to ask?", text: $question)
            }

            Section("Options") {
                ForEach(0..<options.count, id: \.self) { index in
                    HStack {
                        TextField("Option \(index + 1)", text: $options[index])

                        if options.count > 2 {
                            Button {
                                options.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }

                if options.count < 6 {
                    Button {
                        options.append("")
                    } label: {
                        Label("Add Option", systemImage: "plus.circle")
                    }
                }
            }

            Section {
                Toggle("Allow multiple selections", isOn: $allowMultiple)

                Toggle("Set deadline", isOn: $hasDeadline)

                if hasDeadline {
                    DatePicker("Closes on", selection: $deadline, in: Date()...)
                }
            }
        }
        .navigationTitle("Create Poll")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    dismiss()
                }
                .disabled(question.isEmpty || options.filter { !$0.isEmpty }.count < 2)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreatePostView()
    }
}
