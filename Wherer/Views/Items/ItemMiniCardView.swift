import SwiftUI

struct ItemMiniCardView: View {
    let item: Item

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let filename = item.wrappedPhotoFilename,
               let image = PhotoService.loadPhoto(filename: filename) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 80)
                    .overlay(
                        Image(systemName: item.wrappedCategory.icon)
                            .foregroundColor(.gray)
                    )
            }
            Text(item.wrappedName)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
            Text(item.wrappedLocation)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}
