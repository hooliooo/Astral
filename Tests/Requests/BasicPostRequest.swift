////
////  Astral
////  Copyright (c) Julio Miguel Alorro
////  Licensed under the MIT license. See LICENSE file
////
//
//import Foundation
//import Astral
//
//struct BasicPostRequest: Request {
//
//    let configuration: RequestConfiguration = BasicConfiguration()
//
//    let method: HTTPMethod = .post
//
//    let pathComponents: [String] = [
//        "post"
//    ]
//
//    let parameters: Parameters = Parameters.dict([
//        "this": "that",
//        "what": "where",
//        "why": "what"
//    ])
//
//    let headers: Set<Header> = [
//        Header(key: Header.Key.custom("Get-Request"), value: Header.Value.custom("Yes"))
//    ]
//
//    let cachePolicy: URLRequest.CachePolicy? = nil
//}
