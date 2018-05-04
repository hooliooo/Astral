//
//  NestedParametersGetRequest.swift
//  AstralTests
//
//  Created by Julio Miguel Alorro on 5/4/18.
//

import Foundation
import Astral

struct NestedParametersGetRequest: Request {

    let configuration: RequestConfiguration = BasicConfiguration()

    let method: HTTPMethod = .get

    let pathComponents: [String] = [
        "get"
    ]

    let parameters: [String: Any] = [
        "nested": ["aDict": "someValue"],
        "anotherNested": ["anotherDict": 3],
        "nestedArray": ["this", "that", "what"]
    ]

    let headers: Set<Header> = [
        Header(key: Header.Field.custom("Get-Request"), value: Header.Value.custom("YES")),
        Header(key: Header.Field.accept, value: Header.Value.mediaType(MediaType.applicationJSON)),
        Header(key: Header.Field.contentType, value: Header.Value.mediaType(MediaType.applicationJSON))
    ]
}
