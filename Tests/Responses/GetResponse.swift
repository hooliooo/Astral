//
//  Astral
//  Copyright (c) 2017-2019 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

public struct GetResponse: Decodable {

    public enum CodingKeys: String, CodingKey {
        case args
        case headers
        case url
    }

    public let args: BinData
    public let headers: BinHeaders
    public let url: URL

}
