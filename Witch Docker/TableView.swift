//
//  TableView.swift
//  Witch Docker
//
//  Created by Glen Schrader on 2014-11-02.
//  Copyright (c) 2014 Glen Schrader. All rights reserved.
//

import Foundation
import Cocoa

class TableView: NSTableView {
    @IBOutlet var controller: NSObject!

    override func menuForEvent(event: NSEvent) -> NSMenu? {
        let menu = super.menuForEvent(event)
        while (menu?.numberOfItems > 3) {
            menu?.removeItemAtIndex(3)
        }

        if (selectedRow >= 0) {
            let docker = (controller as! PopoverViewController).docker
            let container = docker.containers[selectedRow] as! Container
            
            for (port: String) in container.ports {
                let item = NSMenuItem(title: "Browse to \(port)", action: Selector("test:"), keyEquivalent: "")
                item.representedObject = port
                menu?.addItem(item)
            }
        }

        return menu
    }
    
    func test(sender: AnyObject) {
        let port = sender.representedObject as! String
        let docker = (controller as! PopoverViewController).docker
            
        var url : NSURL = NSURL(string: "http://\(docker.ip):\(port)")!
//            NSApplication.sharedApplication().openURL(url)
        NSWorkspace.sharedWorkspace().openURL(url)
    }
    
    @IBAction func connectMenuItemPress(sender: AnyObject) {
        let docker = (controller as! PopoverViewController).docker
        let container = docker.containers[selectedRow] as! Container
     
        let script = NSAppleScript(source: "tell application \"Terminal\" to do script \"boot2docker ssh docker exec -it \(container.containerId) bash\"")
        script?.executeAndReturnError(nil)

        NSAppleScript(source: "tell application \"Terminal\"\n activate\nend tell")?.executeAndReturnError(nil)
    }
    
    @IBAction func removeMenuItemPress(sender: AnyObject) {
        let docker = (controller as! PopoverViewController).docker
        let container = docker.containers[selectedRow] as! Container
        docker.removeContainer(container)
        (controller as! PopoverViewController).reloadMenuItemPress(sender)
    }

}