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

        let fb = FritzBox(ip: "192.168.178.1")
        fb.fetchDevices() { devices in
            menu.items.removeAll()

            let online = devices.filter({ $0.online })
            self.addDevicesToMenu(devices: online, to: menu)

            menu.addItem(NSMenuItem.separator())

            let offline = devices.filter({ !$0.online })
            self.addDevicesToMenu(devices: offline, to: menu)

            self.appendQuitMenuItem(to: menu)
        }
    }

    private func addDevicesToMenu(devices: [NetworkDevice], to menu: NSMenu) {
        for device in devices {
            let deviceItem = NSMenuItem(
                title: "",
                action: nil,
                keyEquivalent: ""
            )

            let title = NSMutableAttributedString()
            let onlineSymbolTitle = NSAttributedString(
                string: "⬤  ",
                attributes: [
                    .foregroundColor:
                        device.online
                            ? NSColor(red: 0, green: 0.8, blue: 0, alpha: 0.3)
                            : NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.3),
                    .font: NSFont.systemFont(ofSize: 10),
                    .baselineOffset: 2
                ]
            )

            let deviceTitle = NSAttributedString(string: device.name)
            let deviceIp = NSAttributedString(
                string: "  \(device.ip)",
                attributes: [
                    .foregroundColor: NSColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5)
                ]
            )

            title.append(onlineSymbolTitle)
            title.append(deviceTitle)
            title.append(deviceIp)

            deviceItem.attributedTitle = title
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

