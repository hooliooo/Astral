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

    let parameters: [String: Any] = [
        "this": "that",
        "what": "where",
        "why": "what"
    ]

    let headers: Set<Header> = [
        Header(key: Header.Field.custom("Get-Request"), value: Header.Value.custom("YES")),
        Header(key: Header.Field.accept, value: Header.Value.mediaType(MediaType.applicationJSON)),
        Header(key: Header.Field.contentType, value: Header.Value.mediaType(MediaType.applicationJSON))
    ]
}
