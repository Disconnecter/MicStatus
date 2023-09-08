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
    
    private let script = NSAppleScript(source: "input volume of (get volume settings)")
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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            self?.setIcon()
        }
        statusItem.menu = mainMenu
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

    func applicationWillTerminate(_ aNotification: Notification) {
        guard timer?.isValid ?? true else {
            return
        }
        timer?.invalidate()
        timer = nil
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
