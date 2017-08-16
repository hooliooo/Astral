//
//  TestStructs.swift
//  Astral
//
//  Created by Julio Alorro on 6/13/17.
//  Copyright (c) 2017 CocoaPods. All rights reserved.
//

import Astral

struct JSONConfiguration: RequestConfiguration {
    var scheme: URLScheme {
        return .https
    }

    var host: String {
        return "httpbin.org"
    }

    var basePathComponents: [String] {
        return []
    }

    var baseHeaders: [String : Any] {
        return [
            "Content-Type": "application/json"
        ]
    }
}

struct FormURLEncodedConfiguration: RequestConfiguration {
    var scheme: URLScheme {
        return .https
    }

    var host: String {
        return "httpbin.org"
    }

    var basePathComponents: [String] {
        return []
    }

    var baseHeaders: [String : Any] {
        return [
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "application/json"
        ]
    }
}

struct HTTPBinGetRequest: Request {
    var configuration: RequestConfiguration {
        return JSONConfiguration()
    }

    var method: HTTPMethod {
        return .GET
    }

    var pathComponents: [String] {
        return [
            "get"
        ]
    }

    var parameters: [String : Any] {
        return [
            "this": "that"
        ]
    }

    var headers: [String : Any] {
        return [
            "Get-Request": "YES"
        ]
    }
}

struct HTTPBinPostRequest: Request {
    var configuration: RequestConfiguration {
        return FormURLEncodedConfiguration()
    }

    var method: HTTPMethod {
        return .POST
    }

    var pathComponents: [String] {
        return [
            "post"
        ]
    }

    var parameters: [String : Any] {
        return [
            "this": "that"
        ]
    }

    var headers: [String : Any] {
        return [
            "Post-Request": "Yes"
        ]
    }
}
