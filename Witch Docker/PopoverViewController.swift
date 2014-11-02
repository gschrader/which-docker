//
//  PopoverController.swift
//  Witch Docker
//
//  Created by Glen Schrader on 2014-11-01.
//  Copyright (c) 2014 Glen Schrader. All rights reserved.
//

import Foundation
import Cocoa

class PopoverViewController: NSViewController, NSTableViewDataSource {
    @IBOutlet var cogwheelMenu: NSMenu!
    @IBOutlet var tableViewlMenu: NSMenu!
    var docker: Docker = Docker()

    @IBOutlet var tableView: NSTableView!

    @IBAction func cogwheelMenuPress(sender: AnyObject) {
        NSMenu.popUpContextMenu(cogwheelMenu, withEvent: NSApplication.sharedApplication().currentEvent!, forView: sender as NSButton)
    }

    @IBAction func reloadMenuItemPress(sender: AnyObject) {
        self.docker.findContainers()
        self.tableView.reloadData()
    }
    
    @IBAction func aboutMenuItemPress(sender: AnyObject) {
        NSApp.orderFrontStandardAboutPanel(sender)
    }
    
    @IBAction func quitMenuItemPress(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }

    func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
        return self.docker.containers.count
    }

    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        var container: Container = self.docker.containers[row] as Container

        if let view = tableView.makeViewWithIdentifier(tableColumn.identifier, owner: self) as? NSTableCellView {
            var textField = view.textField

            let identifier = tableColumn.identifier!
            switch identifier {
            case "name":
                textField?.stringValue = container.name
            case "image":
                textField?.stringValue = container.image
            default:
                break
            }

            return view
        }
        return nil
    }

    func test(sender: AnyObject?) {
        println("clicked the test button, \(sender)")
    }
}

