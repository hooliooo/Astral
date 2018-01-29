//
//  HTTPBinPostRequest.swift
//  AstralTests
//
//  Created by Julio Alorro on 1/28/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Astral

struct HTTPBinPostRequest: Request {

    let configuration: RequestConfiguration = FormURLEncodedConfiguration()

    let method: HTTPMethod = .post

    let pathComponents: [String] = [
        "post"
    ]

    let parameters: [String: Any] = [
        "this": "that"
    ]

    let headers: Set<Header> = Set<Header>(arrayLiteral:
        Header(key: Header.Field.custom("Post-Request"), value: Header.Value.custom("Yes"))
    )
}
