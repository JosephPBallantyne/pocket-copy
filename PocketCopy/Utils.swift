import AppKit
import Foundation

struct ClipboardUtils {
    
    static func simulatePaste() {
        let source = CGEventSource(stateID: .combinedSessionState)
        
        // Create key events
        let keyVDown = CGEvent(
            keyboardEventSource: source,
            virtualKey: VirtualKey.v,
            keyDown: true
        )
        let keyVUp = CGEvent(
            keyboardEventSource: source,
            virtualKey: VirtualKey.v,
            keyDown: false
        )
        let cmdDown = CGEvent(
            keyboardEventSource: nil,
            virtualKey: VirtualKey.command,
            keyDown: true
        )
        let cmdUp = CGEvent(
            keyboardEventSource: nil,
            virtualKey: VirtualKey.command,
            keyDown: false
        )
        
        // Set command modifier and post events
        keyVDown?.flags = ModifierFlags.command
        cmdDown?.post(tap: .cghidEventTap)
        keyVDown?.post(tap: .cghidEventTap)
        
        keyVUp?.flags = ModifierFlags.command
        cmdUp?.post(tap: .cghidEventTap)
        keyVUp?.post(tap: .cghidEventTap)
    }
    
    static func simulateCopy() {
        let source = CGEventSource(stateID: .combinedSessionState)
        
        // Create key events
        let keyCDown = CGEvent(
            keyboardEventSource: source,
            virtualKey: VirtualKey.c,
            keyDown: true
        )
        let keyCUp = CGEvent(
            keyboardEventSource: source,
            virtualKey: VirtualKey.c,
            keyDown: false
        )
        let cmdDown = CGEvent(
            keyboardEventSource: nil,
            virtualKey: VirtualKey.command,
            keyDown: true
        )
        let cmdUp = CGEvent(
            keyboardEventSource: nil,
            virtualKey: VirtualKey.command,
            keyDown: false
        )
        
        // Set command modifier and post events
        keyCDown?.flags = ModifierFlags.command
        cmdDown?.post(tap: .cghidEventTap)
        keyCDown?.post(tap: .cghidEventTap)
        
        keyCUp?.flags = ModifierFlags.command
        cmdUp?.post(tap: .cghidEventTap)
        keyCUp?.post(tap: .cghidEventTap)
    }
    
    static func simulateUndo() {
        let source = CGEventSource(stateID: .combinedSessionState)
        
        // Create key events
        let keyZDown = CGEvent(
            keyboardEventSource: source,
            virtualKey: VirtualKey.z,
            keyDown: true
        )
        let keyZUp = CGEvent(
            keyboardEventSource: source,
            virtualKey: VirtualKey.z,
            keyDown: false
        )
        let cmdDown = CGEvent(
            keyboardEventSource: nil,
            virtualKey: VirtualKey.command,
            keyDown: true
        )
        let cmdUp = CGEvent(
            keyboardEventSource: nil,
            virtualKey: VirtualKey.command,
            keyDown: false
        )
        
        // Set command modifier and post events
        keyZDown?.flags = ModifierFlags.command
        cmdDown?.post(tap: .cghidEventTap)
        keyZDown?.post(tap: .cghidEventTap)
        
        keyZUp?.flags = ModifierFlags.command
        cmdUp?.post(tap: .cghidEventTap)
        keyZUp?.post(tap: .cghidEventTap)
    }
    
   
}
