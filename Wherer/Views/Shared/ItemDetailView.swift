import SwiftUI

struct ItemDetailView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var spaceStore: SpaceStore
    @Environment(\.dismiss) private var dismiss

    let item: Item
    @State private var showingEdit = false
    @State private var showingDeleteConfirm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let filename = item.wrappedPhotoFilename,
                   let image = PhotoService.loadPhoto(filename: filename) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
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
