////
////  Astral
////  Copyright (c) Julio Miguel Alorro
////  Licensed under the MIT license. See LICENSE file
////
//
//import Foundation
//import Astral
//
//struct NestedParametersGetRequest: Request {
//
//    let configuration: RequestConfiguration = BasicConfiguration()
//
//    let method: HTTPMethod = .get
//
//    let pathComponents: [String] = [
//        "get"
//    ]
//
//    let parameters: Parameters = Parameters.dict([
//        "nested": ["aDict": "someValue"],
//        "anotherNested": ["anotherDict": 3],
//        "nestedArray": ["this", "that", "what"]
//    ])
//
//    let headers: Set<Header> = [
//        Header(key: Header.Key.custom("Get-Request"), value: Header.Value.custom("YES")),
//        Header(key: Header.Key.accept, value: Header.Value.mediaType(MediaType.applicationJSON)),
//        Header(key: Header.Key.contentType, value: Header.Value.mediaType(MediaType.applicationJSON))
//    ]
//
//    let cachePolicy: URLRequest.CachePolicy? = nil
//}
