//
//  SoapError.swift
//  FritzBoxActiveDevices
//
//  Created by Michael Neu on 20.05.19.
//  Copyright © 2019 michaelneu. All rights reserved.
//

import Foundation

enum SoapError: Error {
    case noResponse, parseError
}
