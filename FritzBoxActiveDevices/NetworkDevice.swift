//
//  NetworkDevice.swift
//  FritzBoxActiveDevices
//
//  Created by Michael Neu on 20.05.19.
//  Copyright © 2019 michaelneu. All rights reserved.
//

import Foundation

struct NetworkDevice {
    public let ip: String
    public let mac: String
    public let name: String
    public let online: Bool
}

extension NetworkDevice: CustomStringConvertible {
    public var description: String {
        return "\(name) (\(ip))"
    }
}
