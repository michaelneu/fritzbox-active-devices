//
//  SoapMessage.swift
//  FritzBoxActiveDevices
//
//  Created by Michael Neu on 20.05.19.
//  Copyright © 2019 michaelneu. All rights reserved.
//

import Foundation

struct SoapMessage {
    public let actionName: String
    public let serviceType: String
    public let arguments: [String:String]
}

extension SoapMessage: CustomStringConvertible {
    private var argumentBody: String {
        var argumentBody = ""

        for (key, value) in arguments {
            argumentBody += "<s:\(key)>\(value)</s:\(key)>"
        }

        return argumentBody
    }

    private var body: String {
        return "<s:Body><u:\(actionName) xmlns:u=\"\(serviceType)\">\(argumentBody)</u:\(actionName)></s:Body>"
    }

    public var description: String {
        return "<?xml version=\"1.0\" encoding=\"utf-8\"?><s:Envelope s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">\(body)</s:Envelope>"
    }
}
