//
//  FormURLEncodedResponse.swift
//  AstralTests
//
//  Created by Julio Alorro on 2/3/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

struct FormURLEncodedResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case form
        case headers
        case url
    }

    public let form: BinData
    public let headers: BinHeaders
    public let url: URL

}
