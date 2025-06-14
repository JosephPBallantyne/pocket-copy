import SwiftUI
import AppKit

@main
struct PocketCopyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var popover = NSPopover()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard.fill", accessibilityDescription: "PocketCopy")
            button.image?.size = NSSize(width: 16, height: 16)
            button.image?.isTemplate = true // Makes icon adapt to dark/light mode
        }
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Open PocketCopy", action: #selector(openApp), keyEquivalent: "o"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        
        statusBarItem.menu = menu
        
        // Configure the popover
        popover.contentSize = NSSize(width: 480, height: 650)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
        
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)
    }
    
    @objc func openApp() {
        if let button = statusBarItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
