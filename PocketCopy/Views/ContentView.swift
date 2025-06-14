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

struct ContentView: View {
    @StateObject private var clipboardManager = ClipboardManager()

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()

            ScrollView {
                VStack(spacing: 24) {
                    RecentHistory(items: $clipboardManager.historyItems)
                    Divider()
                        .padding(.horizontal, 20)

                    Favourites(items: $clipboardManager.favoriteItemsIndexed)

                }
            }
            .background(Color(NSColor.windowBackgroundColor))
        }
        .onAppear {
            clipboardManager.startGlobalKeyMonitoring()
        }
        .onDisappear {
            clipboardManager.stopGlobalKeyMonitoring()
        }
    }
}

class ClipboardManager: ObservableObject {
    @Published var copyHistory: [String] = []
    @Published var historyItems: [TableItem] = []
    @Published var favoriteItemsIndexed: [IndexedTableItem] = (0...4).map {
        index in
        IndexedTableItem(
            index: index, item: TableItem(text: "", createdAt: Date()))
    }

    @Published var monitor: Any?
    @Published var currentHistoryIndex = 0
    @Published var currentFaveIndex = 0
    @Published var lastHistoryPasteText: String? = nil
    @Published var lastFavePasteText: String? = nil

    init() {
        startKeyboardShortcutsMonitoring()
    }

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

    func startGlobalKeyMonitoring() {
        let _ = print("start GlobalKeyMonitoring!")
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            self.checkClipboard(event: event)
        }

        NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { event in
            self.checkClipboard(event: event)
            self.lastHistoryPasteText = nil
            self.lastFavePasteText = nil
            self.currentHistoryIndex = 0
            self.currentFaveIndex = 0
        }
    }

    func stopGlobalKeyMonitoring() {
        if let monitor = monitor {
            let _ = print("stop GlobalKeyMonitoring!")
            NSEvent.removeMonitor(monitor)
        }
    }

    private func startKeyboardShortcutsMonitoring() {
        KeyboardShortcuts.onKeyDown(for: .cyclePasteRecent) {
            self.cycleHistoryItemsAndPaste()
        }

        KeyboardShortcuts.onKeyDown(for: .cyclePasteFavorites) {
            self.cycleFaveItemsAndPaste()
        }

        KeyboardShortcuts.onKeyDown(for: .faveCopy1) {
            self.saveToFavorites(index: 0)
        }
        KeyboardShortcuts.onKeyDown(for: .faveCopy2) {
            self.saveToFavorites(index: 1)
        }
        KeyboardShortcuts.onKeyDown(for: .faveCopy3) {
            self.saveToFavorites(index: 2)
        }
        KeyboardShortcuts.onKeyDown(for: .faveCopy4) {
            self.saveToFavorites(index: 3)
        }
        KeyboardShortcuts.onKeyDown(for: .faveCopy5) {
            self.saveToFavorites(index: 4)
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

                self.favoriteItemsIndexed[index] = favorite
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
    ContentView()
}
