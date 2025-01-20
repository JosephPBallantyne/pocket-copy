import AppKit
import KeyboardShortcuts
import SwiftUI

struct TableItem: Identifiable {
    let id = UUID()
    let text: String
    let creationDate: Date
}

struct IndexedTableItem: Identifiable {
    let index: Int
    let item: TableItem
    var id: UUID { item.id }
}

struct CopyTextView: View {
    @State private var copyHistory: [String] = []
    @State private var timer: Timer?
    @State private var tableItems: [TableItem] = []
    @State private var monitor: Any?
    @State private var currentIndex = 0
    @State private var lastPasteText: String? = nil
    @State private var save1: String? = "initial save text"

    var indexedItems: [IndexedTableItem] {
        tableItems.enumerated().map { index, item in
            IndexedTableItem(index: index, item: item)
        }
    }

    var body: some View {
        VStack(spacing: 8) {

            Text("Cycle through your most recent copied items")
            Form {
                KeyboardShortcuts.Recorder(
                    "Command: ", name: .cyclePasteRecent)
            }
            ForEach(copyHistory, id: \.self) { item in
                Text(item)
            }
            Table(indexedItems) {
                TableColumn("") { indexedItem in
                    Text("\(indexedItem.index + 1)")
                }
                TableColumn("Text") { indexedItem in
                    Text(indexedItem.item.text)
                }
            }
            Form {
                KeyboardShortcuts.Recorder(
                    "Copy 1: ", name: .copy1);
                KeyboardShortcuts.Recorder( "Paste 1: ", name: .paste1);
            }
            Text(save1 ?? "")
        }
        .onAppear {
            startGlobalKeyMonitoring()
            startKeyboardShortcutsMonitoring()
        }
        .onDisappear {
            timer?.invalidate()
            stopGlobalKeyMonitoring()
        }
        .frame(width: 500)
        VStack {
        }.frame(maxHeight: .infinity)  // Expand to fill available space
    }

    private func startKeyboardShortcutsMonitoring() {
        KeyboardShortcuts.onKeyDown(for: .cyclePasteRecent) {
            cycleItemsAndPaste()
        }
        
        KeyboardShortcuts.onKeyDown(for: .copy1) {
            if let text = NSPasteboard.general.string(forType: .string) {
                let trimmedText = text.trimmingCharacters(
                    in: .whitespacesAndNewlines)

                if trimmedText.isEmpty {
                    return
                }
                
                save1 = trimmedText
            }
        }
        
        KeyboardShortcuts.onKeyDown(for: .paste1) {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(save1 ?? "", forType: .string)

            simulatePaste()
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

        //        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyUp) {
        //            event in
        //            handleGlobalKeyEvent(event: event)
        //        }
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
            let textExists = tableItems.contains { $0.text == trimmedText }

            if textExists || trimmedText.isEmpty {
                return
            }
            let newItem = TableItem(
                text: trimmedText,
                creationDate: Date()
            )
            tableItems.append(newItem)
            tableItems.sort { $0.creationDate < $1.creationDate }
            if tableItems.count > 5 {
                tableItems.removeFirst()
            }
        }
    }

    //    private func handleGlobalKeyEvent(event: NSEvent) {
    //        if event.modifierFlags.contains([.option, .control]) && event.charactersIgnoringModifiers == "v"  {
    //            cycleItemsAndPaste()
    //        }
    //    }

    private func cycleItemsAndPaste() {
        let _ = print("cycluing")
        let currentItem = tableItems[currentIndex]
        if let lastPasteText = lastPasteText, !lastPasteText.isEmpty {
//            simulateDeleteChar(lastPasteText.count)
            selectPreviousCharacters(lastPasteText)
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(currentItem.text, forType: .string)

        simulatePaste()
        lastPasteText = currentItem.text
        currentIndex = (currentIndex + 1) % tableItems.count
        
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
        
        if (words.count > 1) {
            additionalWordCount = words.count - 1
        }

        return (firstWordLength, additionalWordCount)
    }

    private func simulateDeleteChar(_ chars: Int) {
        let source = CGEventSource(stateID: .hidSystemState)

        let keyDown = CGEvent(
            keyboardEventSource: source, virtualKey: 51, keyDown: true)  // Backspace key
        let keyUp = CGEvent(
            keyboardEventSource: source, virtualKey: 51, keyDown: false)  // Backspace key

        keyDown?.flags = CGEventFlags(rawValue: 0)  // No modifiers
        keyUp?.flags = CGEventFlags(rawValue: 0)  // No modifiers

        for _ in 0..<chars {
            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)

        }

    }

    private func selectPreviousCharacters(_ prevWord: String) {
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

        for _ in 0..<firstWordLength+1 {
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
