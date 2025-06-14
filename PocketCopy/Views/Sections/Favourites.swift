import KeyboardShortcuts
import SwiftUI

struct Favourites: View {
    @Binding var items: [IndexedTableItem]

    var body: some View {
        VStack(spacing: 16) {
            ShortcutRow(
                label: "Cycle through favorites",
                shortcutName: .cyclePasteFavorites
            )
            
            Text("Highlight text and use keyboard shortcut to copy to favourite slot")
                .font(.callout) // or .caption, .system(size: 12), etc.
                    .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                ForEach(0..<5) { index in
                    FavouriteRow(
                        index: index,
                        item: index < items.count
                            ? items[index].item
                            : TableItem(text: "", createdAt: Date()),
                        shortcutName: shortcutNameForIndex(index)
                    )
                    if index < 4 {
                        Divider()
                            .background(
                                Color(NSColor.separatorColor).opacity(0.5)
                            )
                    }

                }
            }.background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                )
        }

        .padding(.horizontal, 20)
    }

    private func shortcutNameForIndex(_ index: Int) -> KeyboardShortcuts.Name {
        switch index {
        case 0: return .faveCopy1
        case 1: return .faveCopy2
        case 2: return .faveCopy3
        case 3: return .faveCopy4
        case 4: return .faveCopy5
        default: return .faveCopy1
        }
    }
}
