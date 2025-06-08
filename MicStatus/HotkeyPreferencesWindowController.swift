import Cocoa

class HotkeyPreferencesWindowController: NSWindowController, NSWindowDelegate {
    /// Local monitor used to intercept key events while the preferences window is active.
    var monitor: Any?

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.delegate = self
    }

    func windowWillClose(_ notification: Notification) {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}
