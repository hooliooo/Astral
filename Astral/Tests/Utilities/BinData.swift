//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Astral

public struct BinData: Decodable {

    public enum CodingKeys: String, CodingKey {
        case this
        case what
        case why
    }

    public let this: String
    public let what: String
    public let why: String

}
