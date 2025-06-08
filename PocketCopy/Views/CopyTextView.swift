import AppKit
import Foundation
import KeyboardShortcuts
import SwiftUI

struct TableItem: Identifiable {
    let id: UUID
    let text: String
    let createdAt: Date

    init(text: String, createdAt: Date, id: UUID = UUID()) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}

struct IndexedTableItem: Identifiable {
    let index: Int
    let item: TableItem
    var id: UUID { item.id }
}

struct CopyTextView: View {
    @State private var copyHistory: [String] = []
    @State private var historyItems: [TableItem] = []
    @State private var favoriteItemsIndexed: [IndexedTableItem] = (0...4).map {
        index in
        IndexedTableItem(
            index: index, item: TableItem(text: "", createdAt: Date()))
    }
    @State private var monitor: Any?
    @State private var currentHistoryIndex = 0
    @State private var currentFaveIndex = 0
    @State private var lastHistoryPasteText: String? = nil
    @State private var lastFavePasteText: String? = nil
    @State private var highlightedText: String = ""

    var historyItemsIndexed: [IndexedTableItem] {
        let minCount = 5
        let paddingCount = max(0, minCount - historyItems.count)
        let paddedHistory =
            historyItems
            + (0..<paddingCount).map { _ in
                TableItem(text: "", createdAt: .distantFuture)
            }
        return paddedHistory.prefix(minCount).enumerated().map { index, item in
            IndexedTableItem(index: index, item: item)
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Form {
                KeyboardShortcuts.Recorder(
                    "Cycle through recent history: ",
                    name: .cyclePasteRecent)
            }
            ForEach(copyHistory, id: \.self) { item in
                Text(item)
            }
            Table(historyItemsIndexed) {
                TableColumn("") { indexedItem in
                    Text("\(indexedItem.index + 1)")
                }
                TableColumn("Text") { indexedItem in
                    Text(indexedItem.item.text)
                }
            }
            .frame(width: 500, height: 200)
            Form {
                KeyboardShortcuts.Recorder(
                    "Cycle through favorites: ", name: .cyclePasteFavorites)
                KeyboardShortcuts.Recorder(
                    "Save favorite 1: ", name: .faveCopy1)
                KeyboardShortcuts.Recorder(
                    "Save favorite 2: ", name: .faveCopy2)
                KeyboardShortcuts.Recorder(
                    "Save favorite 3: ", name: .faveCopy3)
                KeyboardShortcuts.Recorder(
                    "Save favorite 4: ", name: .faveCopy4)
                KeyboardShortcuts.Recorder(
                    "Save favorite 5: ", name: .faveCopy5)
            }
            Table(favoriteItemsIndexed) {
                TableColumn("") { indexedItem in
                    Text("\(indexedItem.index+1)")
                }
                TableColumn("Text") { indexedItem in
                    Text(indexedItem.item.text)
                }
            }
            .frame(width: 500, height: 200)
            Text(lastHistoryPasteText ?? "")
            Text(lastFavePasteText ?? "")
        }
        .onAppear {
            startGlobalKeyMonitoring()
            startKeyboardShortcutsMonitoring()
        }
        .onDisappear {
            stopGlobalKeyMonitoring()
        }
        VStack {
        }.frame(maxHeight: .infinity)
    }

    private func startKeyboardShortcutsMonitoring() {
        KeyboardShortcuts.onKeyDown(for: .cyclePasteRecent) {
            cycleHistoryItemsAndPaste()
        }

        KeyboardShortcuts.onKeyDown(for: .cyclePasteFavorites) {
            cycleFaveItemsAndPaste()
        }
        
        KeyboardShortcuts.onKeyDown(for: .faveCopy1) {
            saveToFavorites(index: 0)
        }
        KeyboardShortcuts.onKeyDown(for: .faveCopy2) {
            saveToFavorites(index: 1)
        }
        KeyboardShortcuts.onKeyDown(for: .faveCopy3) {
            saveToFavorites(index: 2)
        }
        KeyboardShortcuts.onKeyDown(for: .faveCopy4) {
            saveToFavorites(index: 3)
        }
        KeyboardShortcuts.onKeyDown(for: .faveCopy5) {
            saveToFavorites(index: 4)
        }
    }

    private func startGlobalKeyMonitoring() {
        let _ = print("start GlobalKeyMonitoring!")
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            checkClipboard(event: event)
        }

        NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { event in
            checkClipboard(event: event)
            lastHistoryPasteText = nil
            lastFavePasteText = nil
            currentHistoryIndex = 0
            currentFaveIndex = 0
        }
    }

    private func stopGlobalKeyMonitoring() {
        if let monitor = monitor {
            let _ = print("stop GlobalKeyMonitoring!")
            NSEvent.removeMonitor(monitor)
        }
    }

    private func checkClipboard(event: NSEvent) {
        if event.type == .keyDown || event.type == .leftMouseDown {
            updateCopyHistoryItems()
        }
    }

    private func updateCopyHistoryItems() {
        if let text = NSPasteboard.general.string(forType: .string) {
            let trimmedText = text.trimmingCharacters(
                in: .whitespacesAndNewlines)

            if trimmedText.isEmpty {
                return
            }

            let textExists = historyItems.contains { $0.text == trimmedText }

            if textExists {
                return
            }

            let newItem = TableItem(
                text: trimmedText,
                createdAt: Date()
            )
            historyItems.append(newItem)
            historyItems.sort { $0.createdAt > $1.createdAt }
            if historyItems.count > 5 {
                historyItems.removeLast()
            }

        }
    }

    private func saveToFavorites(index: Int) {
        guard index >= 0, index <= 4 else {
            print("Index out of bounds (0-4 allowed)")
            return
        }
        ClipboardUtils.simulateCopy()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if let text = NSPasteboard.general.string(forType: .string) {
                let trimmedText = text.trimmingCharacters(
                    in: .whitespacesAndNewlines)

                if trimmedText.isEmpty {
                    return
                }

                let item = TableItem(
                    text: trimmedText, createdAt: Date()
                )
                let favorite = IndexedTableItem(index: index, item: item)

                favoriteItemsIndexed[index] = favorite
            }
        }
        updateCopyHistoryItems()
    }

    private func removeFavorite(at index: Int) {
        favoriteItemsIndexed.removeAll { $0.index == index }
    }

    private func cycleHistoryItemsAndPaste() {
        let currentItem = historyItems[currentHistoryIndex]
        if let lastHistoryPasteText = lastHistoryPasteText,
            !lastHistoryPasteText.isEmpty
        {
            ClipboardUtils.simulateUndo()
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(currentItem.text, forType: .string)

        ClipboardUtils.simulatePaste()

        lastHistoryPasteText = currentItem.text
        currentHistoryIndex = (currentHistoryIndex + 1) % historyItems.count

    }

    private func cycleFaveItemsAndPaste() {
        let currentItem = favoriteItemsIndexed[currentFaveIndex]
        if let lastFavePasteText = lastFavePasteText, !lastFavePasteText.isEmpty
        {
            ClipboardUtils.simulateUndo()
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(currentItem.item.text, forType: .string)

        ClipboardUtils.simulatePaste()

        lastFavePasteText = currentItem.item.text

        let arrLength = favoriteItemsIndexed.count
        var attempts = 0

        currentFaveIndex = (currentFaveIndex + 1) % arrLength
        while favoriteItemsIndexed[currentFaveIndex].item.text.isEmpty
            && attempts < arrLength
        {
            currentFaveIndex = (currentFaveIndex + 1) % arrLength
            attempts += 1
        }
    }
}

#Preview {
    CopyTextView()
}
