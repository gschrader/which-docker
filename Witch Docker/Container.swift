//
//  Container.swift
//  Witch Docker
//
//  Created by Glen Schrader on 2014-11-01.
//  Copyright (c) 2014 Glen Schrader. All rights reserved.
//

import Foundation

class Container {
    let name: String
    let image: String
    let containerId: String
    var ports = [String]()

    init(name: String, image: String, containerId: String, ports: [String]) {
        self.name = name
        self.image = image
        self.containerId = containerId
        self.ports = ports
    }
}