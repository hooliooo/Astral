//
//  TestStructs.swift
//  Astral
//
//  Created by Julio Alorro on 6/13/17.
//  Copyright (c) 2017 CocoaPods. All rights reserved.
//

import Astral

struct HTTPBinBasicResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case args
        case headers
        case url
    }

    public let args: Args
    public let headers: HTTPHeader
    public let url: URL

}

struct Args: Decodable {

    enum CodingKeys: String, CodingKey {
        case this
        case what
        case why
    }

    public let this: String
    public let what: String
    public let why: String

}

struct HTTPHeader: Decodable {

    enum CodingKeys: String, CodingKey {
        case accept = "Accept"
        case contentType = "Content-Type"
        case custom = "Get-Request"
    }

    public let accept: String
    public let contentType: String
    public let custom: String

}
