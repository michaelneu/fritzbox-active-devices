//
//  AppDelegate.swift
//  FritzBoxActiveDevices
//
//  Created by Michael Neu on 20.05.19.
//  Copyright © 2019 michaelneu. All rights reserved.
//

import Cocoa
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    @IBOutlet weak var window: NSWindow!

    public func menuWillOpen(_ menu: NSMenu) {
        menu.items.removeAll()

        menu.addItem(withTitle: "Fetching devices", action: nil, keyEquivalent: "")
        appendQuitMenuItem(to: menu)

        let fb = FritzBox(ip: "192.168.188.1")
        fb.fetchDevices() { devices in
            menu.items.removeAll()

            let online = devices.filter({ $0.online })
            self.addDevicesToMenu(title: "Online", devices: online, to: menu)

            menu.addItem(NSMenuItem.separator())

            let offline = devices.filter({ !$0.online })
            self.addDevicesToMenu(title: "Rest", devices: offline, to: menu)

            self.appendQuitMenuItem(to: menu)
        }
    }

    private func addDevicesToMenu(title: String, devices: [NetworkDevice], to menu: NSMenu) {
        let headingItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        headingItem.isEnabled = false
        menu.addItem(headingItem)

        for device in devices {
            let deviceItem = NSMenuItem(
                title: "- \(device.description)",
                action: nil,
                keyEquivalent: ""
            )

            deviceItem.isEnabled = false
            menu.addItem(deviceItem)
        }
    }

    private func appendQuitMenuItem(to menu: NSMenu) {
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit FritzBox active devices", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    }

    public func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let button = statusItem.button else {
            return
        }

        button.image = NSImage(named: NSImage.Name("Logo"))

        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
    }

    public func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

