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
        
        println(selectedRow)
        let docker = (controller as PopoverViewController).docker
        let container = docker.containers[selectedRow] as Container
        
        let menu = super.menuForEvent(event)
        
        while (menu?.numberOfItems > 3) {
            menu?.removeItemAtIndex(3)
        }
        
        for (port: String) in container.ports {
            let item = NSMenuItem(title: "Browse to \(port)", action: Selector("test:"), keyEquivalent: "")
            item.representedObject = port
            menu?.addItem(item)
        }

        return menu
    }
    
    func test(sender: AnyObject) {
        if let port = sender.representedObject {
            let docker = (controller as PopoverViewController).docker
            
            var url : NSURL = NSURL(string: "http://\(docker.ip):\(port!)")!
//            NSApplication.sharedApplication().openURL(url)
            NSWorkspace.sharedWorkspace().openURL(url)
            
            println("\(port!)")
        }
    }

}