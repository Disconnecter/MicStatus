//
//  AppDelegate.swift
//  MuteMic
//
//  Created by Serhiy Zabolotnyy on 07.09.2023.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var quitMenuAction: NSMenuItem!
    @IBOutlet weak var monitorMenuAction: NSMenuItem!
    @IBOutlet weak var hotkeysMenuAction: NSMenuItem!

    private var hotkeyWindow = HotkeyPreferencesWindowController()
    private var hotkey: Hotkey? = Hotkey.load()
    private var hotkeyMonitor: Any?

    private let script = NSAppleScript(source: "input volume of (get volume settings)")
    private let toggleScript = NSAppleScript(source: """
on getMicrophoneVolume()
    input volume of (get volume settings)
end getMicrophoneVolume
on disableMicrophone()
    set volume input volume 0
end disableMicrophone
on enableMicrophone()
    set volume input volume 100
end enableMicrophone
if getMicrophoneVolume() is greater than 0 then
    disableMicrophone()
else
    enableMicrophone()
end if
""")
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var timer: Timer?
    private var lastVolume: Int32 = -1
    
    private static let iconSize = NSSize(width: 20, height: 20)
    
    private lazy var micOff: NSImage = {
        let image = NSImage(named: "mic_off")
        image?.size = Self.iconSize
        return image ?? NSImage()
    }()
    
    private lazy var micOn: NSImage = {
        let image = NSImage(named: "mic_on")
        image?.size = Self.iconSize
        return image ?? NSImage()
    }()

    private lazy var micDown: NSImage = {
        let image = NSImage(named: "mic_down")
        image?.size = Self.iconSize
        return image ?? NSImage()
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        startTimer()
        statusItem.menu = mainMenu
        quitMenuAction.title = NSLocalizedString("Menu.Quit", comment: "")
        hotkeysMenuAction.title = NSLocalizedString("Menu.Hotkeys", comment: "")
        registerHotkeyMonitor()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        stopTimer()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    @IBAction private func monitoringAction(menuItem: NSMenuItem) {
        guard timer?.isValid ?? false else {
            startTimer()
            return
        }
        stopTimer()
    }

    @IBAction func showHotkeys(_ sender: NSMenuItem) {
        hotkeyWindow.showWindow(nil)
    }
    
    private func setIcon() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let vol = self?.script?.executeAndReturnError(nil), self?.lastVolume != vol.int32Value else {
                return
            }
            DispatchQueue.main.async { [weak self] in
                let isMicOn = vol.int32Value > 0
                self?.lastVolume = vol.int32Value
                self?.statusItem.button?.image = isMicOn ? self?.micOn : self?.micOff
            }
        }
    }

    private func stopTimer() {
        guard timer?.isValid ?? true else {
            return
        }
        timer?.invalidate()
        timer = nil
        monitorMenuAction.title = NSLocalizedString("Menu.Start", comment: "")
        statusItem.button?.image = micDown
        lastVolume = -1
    }
    
    private func startTimer() {
        monitorMenuAction.title = NSLocalizedString("Menu.Stop", comment: "")
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            self?.setIcon()
        }
    }

    func updateHotkey(_ hotkey: Hotkey) {
        self.hotkey = hotkey
        registerHotkeyMonitor()
    }

    private func registerHotkeyMonitor() {
        if let monitor = hotkeyMonitor {
            NSEvent.removeMonitor(monitor)
            hotkeyMonitor = nil
        }
        guard let hotkey = hotkey else { return }
        hotkeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if event.keyCode == hotkey.keyCode && flags.rawValue == hotkey.modifiers {
                self?.toggleMicrophone()
            }
        }
    }

    private func toggleMicrophone() {
        _ = toggleScript?.executeAndReturnError(nil)
    }
}
