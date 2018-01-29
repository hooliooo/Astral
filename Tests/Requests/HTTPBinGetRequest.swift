//
//  HTTPBinGetRequest.swift
//  Astral
//
//  Created by Julio Alorro on 1/28/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Astral

struct HTTPBinGetRequest: Request {

    let configuration: RequestConfiguration = BasicConfiguration()

    let method: HTTPMethod = .get

    let pathComponents: [String] = [
        "get"
    ]

    let parameters: [String: Any] = [
        "this": "that",
        "what": "where",
        "why": "what"
    ]

    let headers: Set<Header> = Set<Header>(arrayLiteral:
        Header(key: Header.Field.custom("Get-Request"), value: Header.Value.custom("YES"))
    )
}
