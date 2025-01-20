import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let cyclePasteRecent = Self("cyclePasteRecent", default: .init(.b, modifiers: [.command, .option]))
    static let copy1 = Self("copy1", default: .init(.n, modifiers: [.command, .control, .option]))
    static let paste1 = Self("paste1", default: .init(.m, modifiers: [.command, .option]))

}
