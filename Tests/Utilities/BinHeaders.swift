//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
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
