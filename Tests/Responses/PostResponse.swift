//
//  Astral
//  Copyright (c) 2017-2019 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

public struct PostResponse: Decodable {

    public enum CodingKeys: String, CodingKey {
        case json
        case headers
        case url
    }

    public let json: BinData
    public let headers: BinHeaders
    public let url: URL

}
