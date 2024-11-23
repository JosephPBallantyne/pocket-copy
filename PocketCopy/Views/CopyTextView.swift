import AppKit
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

    var indexedItems: [IndexedTableItem] {
        tableItems.enumerated().map { index, item in
            IndexedTableItem(index: index, item: item)
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("Copy history:")
            ForEach(copyHistory, id: \.self) { item in
                Text(item)
            }
            Table(indexedItems) {
                TableColumn("Copied text") { indexedItem in
                    Text(indexedItem.item.text)
                }
                TableColumn("Paste command") { indexedItem in
                    Text("ctrl + option + cmd + \(indexedItem.index + 1)")
                }
            }
        }
        .onAppear {
//            startClipboardPolling()
            startGlobalKeyMonitoring()
        }
        .onDisappear {
            timer?.invalidate()
            stopGlobalKeyMonitoring()
        }
        .frame(width: 500)
        VStack() {
        }.frame( maxHeight: .infinity) // Expand to fill available space
    }

//    private func updateCopyHistory() {
//        if let text = NSPasteboard.general.string(forType: .string) {
//            if !copyHistory.contains(text) && !text.isEmpty {
//                copyHistory.insert(text, at: 0)
//                if copyHistory.count > 5 {
//                    copyHistory.removeLast()
//                }
//            }
//        }
//    }

    private func startGlobalKeyMonitoring() {
        let _ = print("start   GlobalKeyMonitoring!")
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            checkClipboard(event: event)
        }
        
        NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { event in
            checkClipboard(event: event)
        }

        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) {
            event in
            handleGlobalKeyEvent(event: event)
        }

    }

    private func stopGlobalKeyMonitoring() {
        if let monitor = monitor {
            let _ = print("stop   GlobalKeyMonitoring!")

            NSEvent.removeMonitor(monitor)
        }
    }
    
    private func checkClipboard(event: NSEvent) {
        if event.type == .keyDown || event.type == .leftMouseDown {
            updateCopyHistoryItems()
        }
    }

    private func updateCopyHistoryItems() {
        let _ = print("checking loop")
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
    
    private func handleGlobalKeyEvent(event: NSEvent) {
        let controlPressed = event.modifierFlags.contains(.control)
        let optionPressed = event.modifierFlags.contains(.option)
 
        guard controlPressed && optionPressed else { return }

        // Match the key code for numbers 1-5
        switch event.keyCode {
        case 18:  // Key 1
            pasteItem(at: 0)
        case 19:  // Key 2
            pasteItem(at: 1)
        case 20:  // Key 3
            pasteItem(at: 2)
        case 21:  // Key 4
            pasteItem(at: 3)
        case 23:  // Key 5
            pasteItem(at: 4)
        default:
            break
        }
    }

    private func pasteItem(at index: Int) {
        guard index < tableItems.count else { return }

        // Set clipboard content
        let text = tableItems[index].text
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)

        // Simulate Command + V (paste)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let pasteEvent = CGEvent(
                keyboardEventSource: nil, virtualKey: 9, keyDown: true)  // 'V'
            pasteEvent?.flags = .maskCommand
            pasteEvent?.post(tap: .cghidEventTap)
        }
    }

  

    //    private func startClipboardPolling() {
    //        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
    //            _ in updateCopyHistoryItems()
    //
    //        }
    //    }

}

#Preview {
    CopyTextView()
}
