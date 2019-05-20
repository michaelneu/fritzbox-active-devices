//
//  FritzBox.swift
//  FritzBoxActiveDevices
//
//  Created by Michael Neu on 20.05.19.
//  Copyright © 2019 michaelneu. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyXMLParser

class FritzBox {
    public let ip: String

    public init(ip: String) {
        self.ip = ip
    }

    private func sendSoapRequest(to url: String, message: SoapMessage, completion: @escaping (_ result: Result<XML.Accessor>) -> Void) {
        guard let url = URL(string: url) else {
            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = message.description.data(using: .utf8)

        request.addValue("\(message.serviceType)#\(message.actionName)", forHTTPHeaderField: "soapaction")
        request.addValue("text/xml", forHTTPHeaderField: "Content-Type")
        request.addValue("utf-8", forHTTPHeaderField: "Charset")

        Alamofire.request(request).responseString { response in
            guard let value = response.result.value else {
                completion(.failure(SoapError.noResponse))
                return
            }

            guard let xml = try? XML.parse(value) else {
                completion(.failure(SoapError.parseError))
                return
            }

            completion(.success(xml))
        }
    }

    private func fetchDeviceCount(completion: @escaping (_ result: Int) -> Void) {
        let message = SoapMessage(
            actionName: "GetHostNumberOfEntries",
            serviceType: "urn:dslforum-org:service:Hosts:1",
            arguments: [:]
        )

        sendSoapRequest(to: "http://\(ip):49000/upnp/control/hosts", message: message) { result in
            guard let xml = result.value else {
                completion(0)
                return
            }

            let tag = xml["s:Envelope", 0, "s:Body", 0, "u:GetHostNumberOfEntriesResponse", "NewHostNumberOfEntries"]

            guard let text = tag.text, let value = Int(text) else {
                completion(0)
                return
            }

            completion(value)
        }
    }

    private func fetchDevice(index: Int, completion: @escaping (_ device: NetworkDevice) -> Void) {
        let message = SoapMessage(
            actionName: "GetGenericHostEntry",
            serviceType: "urn:dslforum-org:service:Hosts:1",
            arguments: [
                "NewIndex": "\(index)"
            ]
        )

        sendSoapRequest(to: "http://\(ip):49000/upnp/control/hosts", message: message) { result in
            let unknownDevice = NetworkDevice(ip: "n/a", mac: "n/a", name: "n/a", online: false)

            guard let xml = result.value else {
                completion(unknownDevice)
                return
            }

            let ipTag = xml["s:Envelope", 0, "s:Body", 0, "u:GetGenericHostEntryResponse", 0, "NewIPAddress"]
            let macTag = xml["s:Envelope", 0, "s:Body", 0, "u:GetGenericHostEntryResponse", 0, "NewMACAddress"]
            let activeTag = xml["s:Envelope", 0, "s:Body", 0, "u:GetGenericHostEntryResponse", 0, "NewActive"]
            let hostNameTag = xml["s:Envelope", 0, "s:Body", 0, "u:GetGenericHostEntryResponse", 0, "NewHostName"]

            guard let ip = ipTag.text,
                let mac = macTag.text,
                let active = activeTag.text,
                let hostName = hostNameTag.text else {
                completion(unknownDevice)
                return
            }

            let device = NetworkDevice(ip: ip, mac: mac, name: hostName, online: active == "1")
            completion(device)
        }
    }

    public func fetchDevices(completion: @escaping (_ devices: [NetworkDevice]) -> Void) {
        fetchDeviceCount() { count in
            var devices: [NetworkDevice] = []

            for i in 0..<count {
                self.fetchDevice(index: i) { device in
                    devices.append(device)

                    if devices.count == count {
                        devices.sort(by: { a, b in
                            return a.name > b.name
                        })

                        devices.reverse()
                        completion(devices)
                    }
                }
            }
        }
    }
}
