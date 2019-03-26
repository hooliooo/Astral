//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation
import Astral

struct FormURLEncodedConfiguration: RequestConfiguration {

    let scheme: URLScheme = .https

    let host: String = "httpbin.org"

    let basePathComponents: [String] = []

    let baseHeaders: Set<Header> = [
        Header(key: Header.Key.contentType, value: Header.Value.mediaType(MediaType.applicationURLEncoded)),
        Header(key: Header.Key.accept, value: Header.Value.mediaType(MediaType.applicationJSON))
    ]
}
