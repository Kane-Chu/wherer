import SwiftUI

struct ItemDetailView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var spaceStore: SpaceStore
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var item: Item
    @State private var showingEdit = false
    @State private var showingDeleteConfirm = false
    @State private var previewImage: PreviewImage?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if !item.photoList.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(item.photoList.enumerated()), id: \.offset) { index, photo in
                                if let image = PhotoService.loadPhoto(filename: photo.wrappedFilename) {
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 280, height: 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .onTapGesture {
                                                previewImage = PreviewImage(image: image)
                                            }

                                        if photo.wrappedIsCover {
                                            Text("封面")
                                                .font(.caption2.weight(.bold))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.orange)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                                .padding(8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else if let filename = item.photoFilename,
                          let image = PhotoService.loadPhoto(filename: filename) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .onTapGesture {
                            previewImage = PreviewImage(image: image)
                        }
                }

                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(title: "名称", value: item.wrappedName)
                    DetailRow(title: "位置", value: item.wrappedLocation)
                    DetailRow(title: "空间", value: item.wrappedSpace?.wrappedName ?? "-")
                    DetailRow(title: "类型", value: item.wrappedCategory.rawValue)
                    if !item.wrappedTags.isEmpty {
                        HStack {
                            Text("标签")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(width: 60, alignment: .leading)
                            HStack(spacing: 6) {
                                ForEach(item.wrappedTags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.accentColor.opacity(0.12))
                                        .foregroundColor(.accentColor)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    DetailRow(title: "更新于", value: item.wrappedUpdatedAt.formatted())
                }

                Spacer()

                Button(role: .destructive) {
                    showingDeleteConfirm = true
                } label: {
                    Label("删除物品", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle(item.wrappedName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("编辑") {
                    showingEdit = true
                }
                .disabled(item.wrappedSpace == nil)
            }
        }
        .sheet(isPresented: $showingEdit) {
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
    }
}

struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            Text(value)
                .font(.body)
            Spacer()
        }
    }
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
