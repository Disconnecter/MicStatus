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
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var monitor: MicHardwareMonitor?
    
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
        startMonitor()
        statusItem.menu = mainMenu
        quitMenuAction.title = NSLocalizedString("Menu.Quit", comment: "")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        stopMonitor()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    @IBAction private func monitoringAction(menuItem: NSMenuItem) {
        guard monitor == nil else {
            stopMonitor()
            return
        }
        startMonitor()
    }

    private func stopMonitor() {
        monitor?.stop()
        monitor = nil
        monitorMenuAction.title = NSLocalizedString("Menu.Start", comment: "")
        statusItem.button?.image = micDown
    }

    private func startMonitor() {
        monitorMenuAction.title = NSLocalizedString("Menu.Stop", comment: "")
        monitor = MicHardwareMonitor { [weak self] isOn in
            DispatchQueue.main.async {
                self?.statusItem.button?.image = isOn ? self?.micOn : self?.micOff
            }
        }
    }
}
