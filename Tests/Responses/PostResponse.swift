//
//  PostResponse.swift
//  AstralTests
//
//  Created by Julio Alorro on 2/3/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

struct PostResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case json
        case headers
        case url
    }

    public let json: BinData
    public let headers: BinHeaders
    public let url: URL

}
