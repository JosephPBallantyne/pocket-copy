import SwiftUI
import AppKit

struct HighlightableTextView: NSViewRepresentable {
    @ObservedObject var highlightTextManager: HighlightTextManager

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: HighlightableTextView

        init(parent: HighlightableTextView) {
            self.parent = parent
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            let _ = print("textViewDidChangeSelection")
            guard let textView = notification.object as? NSTextView else { return }
            parent.updateHighlightedText(from: textView)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isSelectable = true
        textView.font = NSFont.systemFont(ofSize: 18)
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {}

    // Function to get the selected text
    func updateHighlightedText(from textView: NSTextView) {
        if let selectedRange = textView.selectedRanges.first as? NSRange {
            let string = textView.string as NSString
            let highlightedText = string.substring(with: selectedRange)
            let _ = print("updateHighlightedText")
            let _ = print(highlightedText)

            highlightTextManager.highlightedText = highlightedText
        }
    }
}
