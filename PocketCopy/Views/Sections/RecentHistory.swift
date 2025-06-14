import KeyboardShortcuts
import SwiftUI

struct RecentHistory: View {
    @Binding var items: [TableItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ShortcutRow(
                label: "Cycle through recent history",
                shortcutName: .cyclePasteRecent
            ).padding(.horizontal, 20)
                .padding(.top, 20)

            VStack(spacing: 0) {
                ForEach(Array(items.prefix(5).enumerated()), id: \.element.id) {
                    index, item in
                    ItemRow(index: index + 1, text: item.text)

                    if index < 4 {
                        Divider()
                            .background(
                                Color(NSColor.separatorColor).opacity(0.5)
                            )
                    }
                }

                ForEach(items.count..<5, id: \.self) { index in
                    ItemRow(index: index + 1, text: "")

                    if index < 4 {
                        Divider()
                            .background(
                                Color(NSColor.separatorColor).opacity(0.5)
                            )
                    }
                }
            }
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }
}
