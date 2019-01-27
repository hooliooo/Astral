//
//  BasicGetRequest.swift
//  Astral
//
//  Created by Julio Alorro on 1/28/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Astral

struct BasicGetRequest: Request {

    let configuration: RequestConfiguration = BasicConfiguration()

    let method: HTTPMethod = .get

    let pathComponents: [String] = [
        "get"
    ]

    let parameters: Parameters = Parameters.dict([
        "this": "that",
        "what": "where",
        "why": "what"
    ])

    let headers: Set<Header> = [
        Header(key: Header.Key.custom("Get-Request"), value: Header.Value.custom("YES")),
        Header(key: Header.Key.accept, value: Header.Value.mediaType(MediaType.applicationJSON)),
        Header(key: Header.Key.contentType, value: Header.Value.mediaType(MediaType.applicationJSON))
    ]
}
