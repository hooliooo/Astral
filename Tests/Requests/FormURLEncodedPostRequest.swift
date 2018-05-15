//
//  FormURLEncodedPostRequest.swift
//  AstralTests
//
//  Created by Julio Alorro on 2/3/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Astral

struct FormURLEncodedPostRequest: Request {

    let configuration: RequestConfiguration = FormURLEncodedConfiguration()

    let method: HTTPMethod = .post

    let pathComponents: [String] = [
        "post"
    ]

    let parameters: Parameters = Parameters.dict([
        "this": "that",
        "what": "where",
        "why": "what"
    ])

    let headers: Set<Header> = [
        Header(key: Header.Field.custom("Get-Request"), value: Header.Value.custom("Yes"))
    ]
}
