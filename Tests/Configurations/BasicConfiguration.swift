//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation
import Astral

struct BasicConfiguration: RequestConfiguration {

    let scheme: URLScheme = URLScheme.https

    let host: String = "httpbin.org"

    let basePathComponents: [String] = []

    let baseHeaders: Set<Header> = [
        Header(key: Header.Key.contentType, value: Header.Value.mediaType(MediaType.applicationJSON)),
        Header(key: Header.Key.accept, value: Header.Value.mediaType(MediaType.applicationJSON)),
        Header(key: Header.Key.custom("User-Agent"), value: Header.Value.custom("ios:com.julio.alorro.Astral:v2.0.4"))
    ]
}
