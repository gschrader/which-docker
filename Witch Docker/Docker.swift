//
//  Docker.swift
//  Witch Docker
//
//  Created by Glen Schrader on 2014-11-01.
//  Copyright (c) 2014 Glen Schrader. All rights reserved.
//

import Foundation
import Cocoa

class Docker {
    
    var containers: NSMutableArray!
    var ip: String!
    
    init() {
        self.ip = exec("/usr/local/bin/boot2docker ip").componentsSeparatedByString(":")[0]
        println(ip)
        
        self.findContainers()
    }
    
    func findContainers() {

        self.containers = NSMutableArray()
        
        var results = exec("/usr/local/bin/boot2docker ssh docker ps -q").componentsSeparatedByString("\n")
        
        for container in results {
            if (container != "") {
                println(container)
                let data = exec("/usr/local/bin/boot2docker ssh docker inspect \(container)").dataUsingEncoding(NSUTF8StringEncoding)!
                
                let json = JSON(data: data)
                
                let name = json[0]["Name"].stringValue
                let image = json[0]["Config"]["Image"].stringValue
                println(name)
                

                var ports = [String]()

                let portsJson = json[0]["NetworkSettings"]["Ports"]
                if (portsJson != nil) {
                    for (key: String, subJson: JSON) in portsJson {
                        println(key)
                        if (subJson != nil) {
                            let port = subJson[0]["HostPort"].string!
                            println(port)
                            ports.append(port)
                        }
                    }
                }
                
                var newContainer = Container(name: name, image: image, containerId: container, ports: ports)
                
                containers.addObject(newContainer)
            }
        }
    }
    
    func removeContainer(container: Container) {
        exec("/usr/local/bin/boot2docker ssh docker rm -f \(container.containerId)")
    }
    
    func exec(cmd: String) -> String {
        let task = NSTask()
        task.launchPath = "/bin/bash"
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.arguments = ["-c", cmd]
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: NSUTF8StringEncoding)!
        
        return output
    }
}