import KeyboardShortcuts
import SwiftUI

struct FavouriteRow: View {
    let index: Int
    let item: TableItem
    let shortcutName: KeyboardShortcuts.Name

    var body: some View {
        HStack(spacing: 12) {
            Text("\(index + 1)")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .trailing)

            Text(item.text.isEmpty ? "Empty" : item.text)
                .font(.system(size: 13))
                .foregroundColor(
                    item.text.isEmpty ? Color.secondary.opacity(0.5) : .primary
                )
                .italic(item.text.isEmpty)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                KeyboardShortcuts.Recorder("", name: shortcutName)
                    .labelsHidden()
                    .fixedSize()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}


