import SwiftUI
import KeyboardShortcuts

struct ShortcutRow: View {
    let label: String
    let shortcutName: KeyboardShortcuts.Name
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)
            
            Spacer()
            
            KeyboardShortcuts.Recorder("", name: shortcutName)
                .labelsHidden()
                .fixedSize()
        }
    }
}
