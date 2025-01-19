import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleEnabled = Self("toggleEnabled")
    static let cyclePasteRecent = Self("cyclePasteRecent", default: .init(.b, modifiers: [.command, .option]))

}
