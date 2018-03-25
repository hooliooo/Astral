//
//  BinData.swift
//  Astral
//
//  Created by Julio Alorro on 6/13/17.
//  Copyright (c) 2017 CocoaPods. All rights reserved.
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
