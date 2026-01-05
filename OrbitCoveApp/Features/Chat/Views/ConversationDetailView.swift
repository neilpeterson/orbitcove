import SwiftUI
import PhotosUI

struct ConversationDetailView: View {
    let conversation: LocalConversation
    @Bindable var viewModel: ChatViewModel

    @State private var messageText = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [Image] = []
    @State private var showPhotoPicker = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.sm) {
                        ForEach(viewModel.messages, id: \.id) { message in
                            MessageBubble(
                                message: message,
                                isCurrentUser: message.authorId == MockData.currentUser.id,
                                showAvatar: conversation.isGroup
                            )
                            .id(message.id)
                        }
                    }
                    .padding(Theme.Spacing.md)
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Selected images preview
            if !selectedImages.isEmpty {
                selectedImagesPreview
            }

            Divider()

            // Input bar
            inputBar
        }
        .navigationTitle(conversation.displayName(currentUserId: MockData.currentUser.id))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if conversation.isGroup {
                    Menu {
                        Button {
                            // View members
                        } label: {
                            Label("View Members", systemImage: "person.3")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .task {
            await viewModel.loadMessages(for: conversation)
            await viewModel.markAsRead(conversation)
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhotos,
            maxSelectionCount: 4,
            matching: .images
        )
        .onChange(of: selectedPhotos) { _, newItems in
            Task {
                selectedImages = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImages.append(Image(uiImage: uiImage))
                    }
                }
            }
        }
    }

    private var selectedImagesPreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(selectedImages.indices, id: \.self) { index in
                    ZStack(alignment: .topTrailing) {
                        selectedImages[index]
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))

                        Button {
                            selectedImages.remove(at: index)
                            selectedPhotos.remove(at: index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .background(Circle().fill(.black.opacity(0.5)))
                        }
                        .offset(x: 4, y: -4)
                    }
                }
            }
            .padding(Theme.Spacing.md)
        }
        .background(Theme.Colors.secondaryBackground)
    }

    private var inputBar: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Button {
                showPhotoPicker = true
            } label: {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(Theme.Colors.primary)
            }

            TextField("Message", text: $messageText, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .background(Theme.Colors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.xl))
                .focused($isInputFocused)
                .lineLimit(1...5)

            Button {
                Task {
                    let content = messageText
                    let mediaUrls = selectedImages.isEmpty ? [] : ["https://example.com/uploaded-image.jpg"]
                    messageText = ""
                    selectedImages = []
                    selectedPhotos = []
                    await viewModel.sendMessage(content: content, mediaUrls: mediaUrls)
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .foregroundStyle(canSend ? Theme.Colors.primary : .gray)
            }
            .disabled(!canSend)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.background)
    }

    private var canSend: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !selectedImages.isEmpty
    }
}

#Preview {
    NavigationStack {
        ConversationDetailView(
            conversation: MockData.conversations[0],
            viewModel: ChatViewModel()
        )
    }
    .environment(AppState())
    .environment(\.services, ServiceContainer.shared)
}
