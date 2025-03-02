import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let cyclePasteRecent = Self("cyclePasteRecent", default: .init(.b, modifiers: [.command, .option]))
    static let cyclePasteFavorites = Self("cyclePasteFavorites", default: .init(.n, modifiers: [.command, .control, .option]))
    static let favePaste1 = Self("favePaste1", default: .init(.m, modifiers: [.command, .option]))
    static let faveCopy1 = Self("faveCopy1", default: .init(.one, modifiers: [.command, .control, .option]))
    static let faveCopy2 = Self("faveCopy2", default: .init(.two, modifiers: [.command, .control, .option]))
    static let faveCopy3 = Self("faveCopy3", default: .init(.three, modifiers: [.command, .control, .option]))
    static let faveCopy4 = Self("faveCopy4", default: .init(.four, modifiers: [.command, .control, .option]))
    static let faveCopy5 = Self("faveCopy5", default: .init(.five, modifiers: [.command, .control, .option]))
}
