import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var isShuttingDown = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            configureWindow(window)
        }

        // Listen for system shutdown/logout
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handlePowerOff),
            name: NSWorkspace.willPowerOffNotification,
            object: nil
        )

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 {
                NSApplication.shared.terminate(nil)
                return nil
            }
            return event
        }
    }

    @objc private func handlePowerOff() {
        isShuttingDown = true
    }

    func applicationWillTerminate(_ notification: Notification) {
        // If it's a voluntary quit (not system shutdown), clear everything
        if !isShuttingDown {
            UserDefaults.standard.removeObject(forKey: "saved_tasks")
        }
    }

    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(nil)
    }

    func windowDidBecomeKey(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            configureWindow(window)
        }
    }

    func configureWindow(_ window: NSWindow) {
        window.setContentSize(NSSize(width: 250, height: 300))
        window.styleMask = [.borderless] // no title, HUD, buttons
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .floating
        window.ignoresMouseEvents = false
        window.isMovable = true
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.delegate = self
        window.setFrameAutosaveName("TodoStickyNote")

        if let superview = window.contentView?.superview {
            superview.wantsLayer = true
            superview.layer?.backgroundColor = NSColor.clear.cgColor
            superview.layer?.masksToBounds = true
        }
    }
}

@main
struct todoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
