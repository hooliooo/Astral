//
//  BinHeaders.swift
//  AstralTests
//
//  Created by Julio Alorro on 2/3/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

struct BinHeaders: Decodable {

    enum CodingKeys: String, CodingKey {
        case accept = "Accept"
        case contentType = "Content-Type"
        case custom = "Get-Request"
    }

    public let accept: String
    public let contentType: String
    public let custom: String

}
