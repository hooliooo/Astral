//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

public struct FormURLEncodedResponse: Decodable {

    public enum CodingKeys: String, CodingKey {
        case form
        case headers
        case url
    }

    public let form: BinData
    public let headers: BinHeaders
    public let url: URL

}
