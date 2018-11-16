//
//  BinHeaders.swift
//  AstralTests
//
//  Created by Julio Alorro on 2/3/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

public struct BinHeaders: Decodable {

    public enum CodingKeys: String, CodingKey {
        case accept = "Accept"
        case contentType = "Content-Type"
        case custom = "Get-Request"
        case userAgent = "User-Agent"
    }

    public let accept: String
    public let contentType: String
    public let custom: String
    public let userAgent: String

}
