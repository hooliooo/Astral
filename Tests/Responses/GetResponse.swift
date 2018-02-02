//
//  GetResponse.swift
//  AstralTests
//
//  Created by Julio Alorro on 2/3/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

struct GetResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case args
        case headers
        case url
    }

    public let args: BinData
    public let headers: BinHeaders
    public let url: URL

}
