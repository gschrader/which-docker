//
//  AppDelegate.swift
//  Which Docker
//
//  Created by Glen Schrader on 2017-10-08.
//  Copyright © 2017 Glen Schrader. All rights reserved.
//

import Cocoa
import LaunchAtLogin


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    var docker: Docker = Docker()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(reload(_:))
        }
        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func reload(_ sender: Any?) {
        self.docker.findContainers()
        constructMenu()
    }

    @objc func browse(_ sender: AnyObject) {
        let port = sender.representedObject as! String
        print( port)

        if let url : URL = URL(string: "http://\(docker.ip):\(port)") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc func startContainer(_ sender: AnyObject) {
        let container = sender.representedObject as! Container
        self.docker.startContainer(container)
        constructMenu()
    }
    
    @objc func stopContainer(_ sender: AnyObject) {
        let container = sender.representedObject as! Container
        self.docker.stopContainer(container)
        constructMenu()
    }

    @objc func execContainer(_ sender: AnyObject) {
        let container = sender.representedObject as! Container
        self.docker.exec(container)
    }
    
    @objc func restartContainer(_ sender: AnyObject) {
        let container = sender.representedObject as! Container
        self.docker.restartContainer(container)
        constructMenu()
    }
    
    @objc func removeContainer(_ sender: AnyObject) {
        let container = sender.representedObject as! Container
        self.docker.removeContainer(container)
        constructMenu()
    }

    @objc func showAbout(_ sender: NSMenuItem) {
        NSApp.orderFrontStandardAboutPanel(sender);
    }
    
    @objc func launchToggle(_ sender: NSMenuItem) {
        if sender.state == NSControl.StateValue.off {
            LaunchAtLogin.isEnabled = false
        } else {
            LaunchAtLogin.isEnabled = true
        }
        print(LaunchAtLogin.isEnabled)
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        for container in docker.containers {
            let containerMenu = NSMenu(title: "\(container.name)")

            if (!container.running) {
                let startMenuItem = NSMenuItem(title: "Start", action: #selector(AppDelegate.startContainer(_:)), keyEquivalent: "")
                startMenuItem.representedObject = container
                containerMenu.addItem(startMenuItem)
            }

            if (container.running) {
                let restartMenuItem = NSMenuItem(title: "Restart", action: #selector(AppDelegate.restartContainer(_:)), keyEquivalent: "")
                restartMenuItem.representedObject = container
                containerMenu.addItem(restartMenuItem)

                let stopMenuItem = NSMenuItem(title: "Stop", action: #selector(AppDelegate.stopContainer(_:)), keyEquivalent: "")
                stopMenuItem.representedObject = container
                containerMenu.addItem(stopMenuItem)

                let execMenuItem = NSMenuItem(title: "Exec", action: #selector(AppDelegate.execContainer(_:)), keyEquivalent: "")
                execMenuItem.representedObject = container
                containerMenu.addItem(execMenuItem)
            }

            containerMenu.addItem(NSMenuItem.separator())

            let removeMenuItem = NSMenuItem(title: "Remove", action: #selector(AppDelegate.removeContainer(_:)), keyEquivalent: "")
            removeMenuItem.representedObject = container
            containerMenu.addItem(removeMenuItem)

            containerMenu.addItem(NSMenuItem.separator())

            containerMenu.addItem(NSMenuItem(title: "Image: \(container.image)", action: nil,  keyEquivalent: ""))
            
            containerMenu.addItem(NSMenuItem.separator())

            if (container.running) {
                for port: String in container.ports {
                    let item = NSMenuItem(title: "Browse to \(port)", action: #selector(AppDelegate.browse(_:)), keyEquivalent: "")
                    item.representedObject = port
                    containerMenu.addItem(item)
                }
            }
            
            let containerMenuItem = NSMenuItem(title: "\(container.name)", action: nil, keyEquivalent: "")

            if (container.running) {
                containerMenuItem.attributedTitle = NSAttributedString(string: "\(container.name)", attributes:[NSAttributedStringKey.font:NSFont.boldSystemFont(ofSize: 16)])
            }

            containerMenuItem.submenu = containerMenu
            menu.addItem(containerMenuItem)
        }

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "Reload", action: #selector(AppDelegate.reload(_:)), keyEquivalent: "r"))

        menu.addItem(NSMenuItem(title: "About Which Docker", action: #selector(AppDelegate.showAbout(_:)), keyEquivalent: ""))

        let launchMenuItem = NSMenuItem.init(title: "Start Which Docker at Login", action: #selector(AppDelegate.launchToggle(_:)), keyEquivalent: "")
        if LaunchAtLogin.isEnabled == true {
            launchMenuItem.state = NSControl.StateValue.on
        } else {
            launchMenuItem.state = NSControl.StateValue.off
        }
        menu.addItem(launchMenuItem)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "Quit Which Docker", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
}

