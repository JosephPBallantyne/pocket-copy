import AppKit
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
    @State private var favoriteItemsIndexed: [IndexedTableItem] = (0...4).map { index in
        IndexedTableItem(index: index, item: TableItem(text: "", createdAt: Date()))
    }
    @State private var monitor: Any?
    @State private var currentHistoryIndex = 0
    @State private var currentFaveIndex = 0
    @State private var lastHistoryPasteText: String? = nil
    @State private var lastFavePasteText: String? = nil
    @State private var highlightedText: String = ""

    var historyItemsIndexed: [IndexedTableItem] {
        let minCount = 5
            let paddedHistory = historyItems + Array(repeating: TableItem(text: "", createdAt: .distantFuture), count: max(0, minCount - historyItems.count))
            
            return paddedHistory.prefix(minCount).enumerated().map { index, item in
                IndexedTableItem(index: index, item: item)
            }
    }

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

        KeyboardShortcuts.onKeyDown(for: .cyclePasteFavorites) {
            cycleFaveItemsAndPaste()
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
        simulateCopy()
        
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
        if let lastHistoryPasteText = lastHistoryPasteText, !lastHistoryPasteText.isEmpty {
            smartDeletePrev(lastHistoryPasteText)
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(currentItem.text, forType: .string)

        simulatePaste()

        lastHistoryPasteText = currentItem.text
        currentHistoryIndex = (currentHistoryIndex + 1) % historyItems.count

    }
    
    private func cycleFaveItemsAndPaste() {
        let currentItem = favoriteItemsIndexed[currentFaveIndex]
        if let lastFavePasteText = lastFavePasteText, !lastFavePasteText.isEmpty {
            smartDeletePrev(lastFavePasteText)
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(currentItem.item.text, forType: .string)

        simulatePaste()

        lastFavePasteText = currentItem.item.text

        
        let arrLength = favoriteItemsIndexed.count
        var attempts = 0

        currentFaveIndex = (currentFaveIndex + 1) % arrLength
        while favoriteItemsIndexed[currentFaveIndex].item.text.isEmpty && attempts < arrLength {
            currentFaveIndex = (currentFaveIndex + 1) % arrLength
            attempts += 1
        }
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
    
    private func simulateCopy() {
        let source = CGEventSource(stateID: .combinedSessionState)

        let keyCDown = CGEvent(
            keyboardEventSource: source, virtualKey: 8, keyDown: true)
        let keyCUp = CGEvent(
            keyboardEventSource: source, virtualKey: 8, keyDown: false)
        let cmdDown = CGEvent(
            keyboardEventSource: nil, virtualKey: 55, keyDown: true)
        let cmdUp = CGEvent(
            keyboardEventSource: nil, virtualKey: 55, keyDown: false)

        keyCDown?.flags = .maskCommand
        cmdDown?.post(tap: .cghidEventTap)
        keyCDown?.post(tap: .cghidEventTap)

        keyCUp?.flags = .maskCommand
        cmdUp?.post(tap: .cghidEventTap)
        keyCUp?.post(tap: .cghidEventTap)
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

        let shiftDown = CGEvent(
            keyboardEventSource: source, virtualKey: 56, keyDown: true)
        let shiftUp = CGEvent(
            keyboardEventSource: source, virtualKey: 56, keyDown: false)

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
        leftArrowDown?.flags = [.maskShift]
        leftArrowUp?.flags = [.maskShift]

        for _ in 0..<firstWordLength + 1 {
            leftArrowDown?.post(tap: .cghidEventTap)
            leftArrowUp?.post(tap: .cghidEventTap)
        }
        
        shiftUp?.post(tap: .cghidEventTap)
        leftArrowDown?.flags = []
        leftArrowUp?.flags = []
        
        backspaceDown?.flags = CGEventFlags(rawValue: 0)
        backspaceUp?.flags = CGEventFlags(rawValue: 0)
        backspaceDown?.post(tap: .cghidEventTap)
        backspaceUp?.post(tap: .cghidEventTap)
    }
}

#Preview {
    CopyTextView()
}
