//
//  AppDelegate.swift
//  Witch Docker
//
//  Created by Glen Schrader on 2014-11-01.
//  Copyright (c) 2014 Glen Schrader. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var popover: NSPopover!
    var popoverTransiencyMonitor: AnyObject?

    let status: StatusView
    
    override init() {
        let statusBar = NSStatusBar.systemStatusBar()
        
        let statusItem = statusBar.statusItemWithLength(-1)
        
        self.status = StatusView(logo: "Status", statusItem: statusItem)
        statusItem.view = status
        super.init()
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Kill services
        // Insert code here to tear down your application
    }
    
    func close() {
        self.popover.close()
        self.status.isSelected = false
    }
    
    override func awakeFromNib() {
        let edge = 1
        let status = self.status
        let rect = status.frame
        status.onMouseDown = {
            if (self.popover.shown) {
                self.close()
            } else {
                self.popoverTransiencyMonitor = NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.LeftMouseDownMask, handler: {(event: NSEvent!) in
                    self.close()
                })!
                self.popover.showRelativeToRect(rect, ofView: status, preferredEdge: edge)
                self.status.isSelected = true
            }
        }
    }
    
    
}

