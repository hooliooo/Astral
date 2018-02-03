//
//  FormURLEncodedConfiguration.swift
//  AstralTests
//
//  Created by Julio Alorro on 1/28/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Astral

struct FormURLEncodedConfiguration: RequestConfiguration {

    let scheme: URLScheme = .https

    let host: String = "httpbin.org"

    let basePathComponents: [String] = []

    let baseHeaders: Set<Header> = [
        Header(key: Header.Field.contentType, value: Header.Value.mediaType(MediaType.applicationURLEncoded)),
        Header(key: Header.Field.accept, value: Header.Value.mediaType(MediaType.applicationJSON))
    ]
}
