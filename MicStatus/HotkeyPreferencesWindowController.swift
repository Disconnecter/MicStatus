import Cocoa

final class HotkeyPreferencesWindowController: NSWindowController {
    private let infoLabel = NSTextField(labelWithString: NSLocalizedString("Prefs.Description", comment: ""))
    private let hotkeyField = NSTextField(string: "")
    private var monitor: Any?

    init() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 80),
                              styleMask: [.titled, .closable],
                              backing: .buffered, defer: false)
        window.title = NSLocalizedString("Prefs.Title", comment: "")
        super.init(window: window)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        guard let content = window?.contentView else { return }
        infoLabel.frame = NSRect(x: 20, y: 48, width: 260, height: 20)
        content.addSubview(infoLabel)

        hotkeyField.frame = NSRect(x: 20, y: 20, width: 260, height: 24)
        hotkeyField.isEditable = false
        content.addSubview(hotkeyField)
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        hotkeyField.stringValue = Hotkey.load()?.displayString ?? ""
        if monitor == nil {
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self else { return event }
                let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
                let hotkey = Hotkey(keyCode: event.keyCode,
                                    modifiers: flags.rawValue,
                                    characters: event.charactersIgnoringModifiers ?? "")
                hotkey.save()
                self.hotkeyField.stringValue = hotkey.displayString
                (NSApplication.shared.delegate as? AppDelegate)?.updateHotkey(hotkey)
                return nil
            }
        }
    }

    deinit {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
