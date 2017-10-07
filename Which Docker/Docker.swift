//
//  Docker.swift
//  Witch Docker
//
//  Created by Glen Schrader on 2014-11-01.
//  Copyright (c) 2014 Glen Schrader. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyJSON
import ReactiveTask
import Result

class Docker {
    
    var containers: [Container] = []
    var ip: String
    
    init() {
//        self.ip = shell(launchPath: "/usr/local/bin/docker-machine", arguments:["ip", "dev"]).components(separatedBy:"\n")[0]
//        println(ip)
        self.ip = "localhost"
        
        self.findContainers()
    }
    
    func findContainers() {
        containers = []
        let results = shell(launchPath: "/usr/local/bin/docker", arguments: ["ps", "-q", "-a"]).components(separatedBy:"\n")
        
        for container in results {
            if (container != "") {
                print(container)
                let data = shell(launchPath: "/usr/local/bin/docker", arguments: ["inspect", container]).data(using: String.Encoding.utf8)!
                
                let json = JSON(data: data)
                
                let name = json[0]["Name"].stringValue
                let index = name.index(name.startIndex, offsetBy: 1)
                let name2 = String(name[index...])
                print(name2)
                let image = json[0]["Config"]["Image"].stringValue
                print(name)
                
                let running = json[0]["State"]["Running"].boolValue
                var ports = [String]()

                let portsJson = json[0]["NetworkSettings"]["Ports"]
                if (portsJson != JSON.null) {
                    for (key, subJson):(String, JSON) in portsJson {
                        print(key)
                        if (subJson != JSON.null) {
                            let port = subJson[0]["HostPort"].string!
                            print(port)
                            ports.append(port)
                        }
                    }
                }
                
                let newContainer = Container(name: name2, image: image, containerId: container, running: running, ports: ports)
                
                containers.append(newContainer)
            }
        }
        
        containers = containers.sorted(by: {
            if $0.running != $1.running {
                return $0.running && !$1.running
            } else {
                return $0.name < $1.name
            }
        })
    }
    
    func startContainer(_ container: Container) {
        let result = shell(launchPath: "/usr/local/bin/docker", arguments: ["start",  container.containerId])
        print(result)
        self.findContainers()
    }
    
    func stopContainer(_ container: Container) {
        let result = shell(launchPath: "/usr/local/bin/docker", arguments: ["stop",  container.containerId])
        print(result)
        self.findContainers()
    }
    
    func removeContainer(_ container: Container) {
        let result = shell(launchPath: "/usr/local/bin/docker", arguments: ["rm", "-f",  container.containerId])
        print(result)
        self.findContainers()
    }
    
    func restartContainer(_ container: Container) {
        let result = shell(launchPath: "/usr/local/bin/docker", arguments: ["restart",  container.containerId])
        print(result)
        self.findContainers()
    }
    
    func exec(_ container: Container) {
        let script = NSAppleScript(source: "tell application \"Terminal\" to do script \"docker exec -it \(container.containerId) bash\"")
        script?.executeAndReturnError(nil)
        

        NSAppleScript(source: "tell application \"Terminal\"\n activate\nend tell")?.executeAndReturnError(nil)
    }

    func browse(_ container: Container, port: String) {
        if let url : URL = URL(string: "http://\(self.ip):\(port)") {
            NSWorkspace.shared.open(url)
        }
    }
    
    func shell(launchPath: String, arguments: [String]) -> String {
        let task = Task(launchPath, arguments: arguments)

        let result: Result<String, TaskError>? = task.launch()
            .ignoreTaskData()
            .map { String(data: $0, encoding: .utf8)! }
            .single()
        
        return (result?.value)!;
    }
}
