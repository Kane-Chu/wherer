import SwiftUI

struct ItemDetailView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var spaceStore: SpaceStore
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    let itemID: UUID
    @State private var photos: [ItemPhoto] = []
    @State private var showingEdit = false
    @State private var showingDeleteConfirm = false
    @State private var previewImage: PreviewImage?

    private var item: Item {
        itemStore.items.first { $0.wrappedId == itemID }!
    }

    private var coverImageSection: some View {
        ZStack {
            coverImageContent
                .frame(height: 260)
                .clipped()

            // Top gradient + buttons
            VStack {
                LinearGradient(
                    colors: [.black.opacity(0.4), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)
                .overlay(alignment: .top) {
                    HStack {
                        backButton
                        Spacer()
                        moreButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
                Spacer()
            }

            // Bottom gradient + title
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, .black.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.wrappedName)
                            .font(.title3.weight(.bold))
                            .foregroundColor(.white)
                        Text(item.wrappedLocation)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(16)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    private var coverImageContent: some View {
        Group {
            if !photos.isEmpty {
                TabView {
                    ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                        if let image = photo.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .onTapGesture {
                                    previewImage = PreviewImage(image: image)
                                }
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: photos.count > 1 ? .always : .never))
            } else if let image = item.coverImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .onTapGesture {
                        previewImage = PreviewImage(image: image)
                    }
            } else {
                Color(.systemGray6)
                    .overlay(
                        Image(systemName: item.wrappedCategory.icon)
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                    )
            }
        }
    }

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
    }

    private var moreButton: some View {
        Menu {
            Button("编辑物品") {
                showingEdit = true
            }
            Button("删除物品", role: .destructive) {
                showingDeleteConfirm = true
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            InfoRow(label: "空间", value: item.wrappedSpace?.wrappedName ?? "-")
            Divider()
            InfoRow(label: "类型", value: item.wrappedCategory.rawValue)
            Divider()
            InfoRow(label: "标签") {
                if !item.wrappedTags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(item.wrappedTags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(themeManager.effectiveColors.tagTint.opacity(themeManager.effectiveColors.tagTintOpacity))
                                .foregroundColor(themeManager.effectiveColors.accent)
                                .cornerRadius(12)
                        }
                    }
                } else {
                    Text("-")
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
            Divider()
            InfoRow(label: "更新于", value: item.wrappedUpdatedAt.formatted())
        }
        .padding(.horizontal, 16)
    }

    var body: some View {
        if itemStore.items.contains(where: { $0.wrappedId == itemID }) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    coverImageSection
                    infoSection
                }
            }
            .id(item.photoList.count)
            .sheet(isPresented: $showingEdit, onDismiss: {
                photos = item.photoList
            }) {
                ItemFormView(space: item.wrappedSpace!, item: item)
                    .environmentObject(itemStore)
                    .environmentObject(spaceStore)
            }
            .alert("确认删除？", isPresented: $showingDeleteConfirm) {
                Button("取消", role: .cancel) {}
                Button("删除", role: .destructive) {
                    itemStore.deleteItem(item)
                    dismiss()
                }
            } message: {
                Text("删除后将无法恢复")
            }
            .fullScreenCover(item: $previewImage) { wrapper in
                ImagePreviewView(image: wrapper.image)
            }
            .onAppear {
                photos = item.photoList
            }
        } else {
            Color.clear
                .onAppear { dismiss() }
        }
    }
}

struct ItemIdentifier: Identifiable {
    let id: UUID
}

struct PreviewImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct ImagePreviewView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScale
                                lastScale = value
                                scale *= delta
                            }
                            .onEnded { _ in
                                withAnimation {
                                    scale = max(1.0, min(scale, 5.0))
                                    lastScale = 1.0
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation {
                            scale = scale > 1.2 ? 1.0 : 3.0
                        }
                    }
            }
            .background(.black)
            .ignoresSafeArea()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("关闭") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct InfoRow<Content: View>: View {
    let label: String
    let content: Content

    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    init(label: String, value: String) where Content == Text {
        self.label = label
        self.content = Text(value)
            .font(.body)
            .foregroundColor(.primary)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            content
        }
        .padding(.vertical, 12)
    }
}
