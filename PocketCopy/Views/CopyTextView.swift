import AppKit
import KeyboardShortcuts
import SwiftUI

struct TableItem: Identifiable {
    let id = UUID()
    let text: String
    let createdAt: Date
}

struct IndexedTableItem: Identifiable {
    let index: Int
    let item: TableItem
    var id: UUID { item.id }
}

struct CopyTextView: View {
    @State private var copyHistory: [String] = []
    @State private var historyItems: [TableItem] = []
    @State private var favoriteItemsIndexed: [IndexedTableItem] = []
    @State private var monitor: Any?
    @State private var currentIndex = 0
    @State private var lastPasteText: String? = nil
    @State private var maxFavorites: Int = 5
    @StateObject private var highlightTextManager = HighlightTextManager()

    var historyItemsIndexed: [IndexedTableItem] {
        historyItems.enumerated().map { index, item in
            IndexedTableItem(index: index, item: item)
        }
    }

    //    var favoriteItemsTable: [IndexedTableItem] {
    //        favoriteItems.enumerated().map { index, item in
    //            IndexedTableItem(index: index, item: item)
    //        }
    //    }

    var body: some View {
        VStack(spacing: 8) {

            Form {
                KeyboardShortcuts.Recorder(
                    "Cycle through recent copy history: ",
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
            .frame(width: 550)
            Form {
                KeyboardShortcuts.Recorder(
                    "Cycle through favorites: ", name: .cyclePasteFavorites)
                KeyboardShortcuts.Recorder(
                    "Save favorite 1: ", name: .faveCopy1)
                KeyboardShortcuts.Recorder(
                    "Save favorite 2: ", name: .faveCopy2)
            }
            Table(favoriteItemsIndexed) {
                TableColumn("") { indexedItem in
                    Text("\(indexedItem.index)")
                }
                TableColumn("Text") { indexedItem in
                    Text(indexedItem.item.text)
                }
            }
            .frame(width: 550)
            Text(lastPasteText ?? "")
        }
        .onAppear {
            startGlobalKeyMonitoring()
            startKeyboardShortcutsMonitoring()
        }
        .onDisappear {
            stopGlobalKeyMonitoring()
        }
        //        .frame(width: 500)
        VStack {
        }.frame(maxHeight: .infinity)  // Expand to fill available space
    }

    private func startKeyboardShortcutsMonitoring() {
        KeyboardShortcuts.onKeyDown(for: .cyclePasteRecent) {
            cycleItemsAndPaste()
        }

        KeyboardShortcuts.onKeyDown(for: .faveCopy1) {
            saveToFavorites(index: 1)
        }
        KeyboardShortcuts.onKeyDown(for: .faveCopy2) {
            saveToFavorites(index: 2)
        }
        KeyboardShortcuts.onKeyDown(for: .faveCopy3) {
            saveToFavorites(index: 3)
        }
        KeyboardShortcuts.onKeyDown(for: .faveCopy4) {
            saveToFavorites(index: 4)
        }
        KeyboardShortcuts.onKeyDown(for: .faveCopy5) {
            saveToFavorites(index: 5)
        }

        KeyboardShortcuts.onKeyDown(for: .cyclePasteFavorites) {

        }
    }

    private func startGlobalKeyMonitoring() {
        let _ = print("start GlobalKeyMonitoring!")
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            checkClipboard(event: event)
        }

        NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { event in
            checkClipboard(event: event)
            lastPasteText = nil
            currentIndex = 0
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
            historyItems.sort { $0.createdAt < $1.createdAt }
            if historyItems.count > 5 {
                historyItems.removeFirst()
            }
        }
    }

    private func saveToFavorites(index: Int) {
        let highlightedText = highlightTextManager.highlightedText
        let trimmedText = highlightedText.trimmingCharacters(
            in: .whitespacesAndNewlines)
        let _ = print(highlightedText)
        let _ = print("highlightedText")

        if trimmedText.isEmpty {
            return
        }

        guard index >= 1, index <= maxFavorites else {
            print("Index out of bounds (1-5 allowed)")
            return
        }

        let item = TableItem(
            text: trimmedText, createdAt: Date()
        )
        let favorite = IndexedTableItem(index: index, item: item)

        // Replace if index already exists
        if let existingIndex = favoriteItemsIndexed.firstIndex(where: {
            $0.index == index
        }) {
            favoriteItemsIndexed[existingIndex] = favorite
        } else {
            favoriteItemsIndexed.append(favorite)
        }

        // Keep sorted by index
        favoriteItemsIndexed.sort { $0.index < $1.index }

    }

    private func removeFavorite(at index: Int) {
        favoriteItemsIndexed.removeAll { $0.index == index }
    }

    private func cycleItemsAndPaste() {
        let _ = print("cycling")
        let currentItem = historyItems[currentIndex]
        if let lastPasteText = lastPasteText, !lastPasteText.isEmpty {
            smartDeletePrev(lastPasteText)
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(currentItem.text, forType: .string)

        simulatePaste()
        let _ = print("lastPasteText  " + (lastPasteText ?? ""))

        lastPasteText = currentItem.text
        currentIndex = (currentIndex + 1) % historyItems.count

    }

    private func simulatePaste() {
        let source = CGEventSource(stateID: .combinedSessionState)

        let keyVDown = CGEvent(
            keyboardEventSource: source, virtualKey: 9, keyDown: true)
        let keyVUp = CGEvent(
            keyboardEventSource: source, virtualKey: 9, keyDown: false)
        let cmdDown = CGEvent(
            keyboardEventSource: nil, virtualKey: 55, keyDown: true)
        let cmdUp = CGEvent(
            keyboardEventSource: nil, virtualKey: 55, keyDown: false)

        keyVDown?.flags = .maskCommand
        cmdDown?.post(tap: .cghidEventTap)
        keyVDown?.post(tap: .cghidEventTap)

        keyVUp?.flags = .maskCommand
        cmdUp?.post(tap: .cghidEventTap)
        keyVUp?.post(tap: .cghidEventTap)
    }

    func analyzeString(_ input: String) -> (
        firstWordLength: Int, additionalWordCount: Int
    ) {
        let words = input.split(separator: " ")
        let firstWordLength = words.first?.count ?? 0
        var additionalWordCount = 0

        if words.count > 1 {
            additionalWordCount = words.count - 1
        }

        return (firstWordLength, additionalWordCount)
    }

    private func smartDeletePrev(_ prevWord: String) {
        let source = CGEventSource(stateID: .combinedSessionState)
        let (firstWordLength, additionalWordCount) = analyzeString(prevWord)
        let _ = print(firstWordLength)
        let _ = print(additionalWordCount)
        //        guard
        let shiftDown = CGEvent(
            keyboardEventSource: source, virtualKey: 56, keyDown: true)
        //        else { return }  // Shift key down
        //        guard
        let shiftUp = CGEvent(
            keyboardEventSource: source, virtualKey: 56, keyDown: false)
        //        else { return }  // Shift key up

        let optionDown = CGEvent(
            keyboardEventSource: source, virtualKey: 58, keyDown: true)
        let optionUp = CGEvent(
            keyboardEventSource: source, virtualKey: 58, keyDown: false)

        let leftArrowDown = CGEvent(
            keyboardEventSource: source, virtualKey: 123, keyDown: true)
        let leftArrowUp = CGEvent(
            keyboardEventSource: source, virtualKey: 123, keyDown: false)

        let backspaceDown = CGEvent(
            keyboardEventSource: source, virtualKey: 51, keyDown: true)
        let backspaceUp = CGEvent(
            keyboardEventSource: source, virtualKey: 51, keyDown: false)

        shiftDown?.flags = CGEventFlags(rawValue: 0)
        shiftUp?.flags = CGEventFlags(rawValue: 0)

        shiftDown?.post(tap: .cghidEventTap)
        optionDown?.post(tap: .cghidEventTap)

        leftArrowDown?.flags = [.maskShift, .maskAlternate]
        leftArrowUp?.flags = [.maskShift, .maskAlternate]

        for _ in 0..<additionalWordCount {
            leftArrowDown?.post(tap: .cghidEventTap)
            leftArrowUp?.post(tap: .cghidEventTap)
        }
        optionUp?.post(tap: .cghidEventTap)

        for _ in 0..<firstWordLength + 1 {
            leftArrowDown?.post(tap: .cghidEventTap)
            leftArrowUp?.post(tap: .cghidEventTap)
        }
        shiftUp?.post(tap: .cghidEventTap)

        backspaceDown?.flags = CGEventFlags(rawValue: 0)
        backspaceUp?.flags = CGEventFlags(rawValue: 0)

        backspaceDown?.post(tap: .cghidEventTap)
        backspaceUp?.post(tap: .cghidEventTap)
    }
}

#Preview {
    CopyTextView()
}
