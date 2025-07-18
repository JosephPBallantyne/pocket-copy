import KeyboardShortcuts
import Foundation
import CoreGraphics

extension KeyboardShortcuts.Name {
    static let cyclePasteRecent = Self("cyclePasteRecent", default: .init(.b, modifiers: [.command, .option]))
    static let cyclePasteFavorites = Self("cyclePasteFavorites", default: .init(.n, modifiers: [.command, .option]))
    static let favePaste1 = Self("favePaste1", default: .init(.m, modifiers: [.command, .option]))
    static let faveCopy1 = Self("faveCopy1", default: .init(.one, modifiers: [.command, .control, .option]))
    static let faveCopy2 = Self("faveCopy2", default: .init(.two, modifiers: [.command, .control, .option]))
    static let faveCopy3 = Self("faveCopy3", default: .init(.three, modifiers: [.command, .control, .option]))
    static let faveCopy4 = Self("faveCopy4", default: .init(.four, modifiers: [.command, .control, .option]))
    static let faveCopy5 = Self("faveCopy5", default: .init(.five, modifiers: [.command, .control, .option]))
}

enum VirtualKey {
    static let c: CGKeyCode = 8
    static let v: CGKeyCode = 9
    static let z: CGKeyCode = 6
    static let command: CGKeyCode = 55
}

enum ModifierFlags {
    static let command: CGEventFlags = .maskCommand
}
