//
//  JSONStrategy.swift
//  Astral
//
//  Created by Julio Alorro on 8/16/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

public struct JSONStrategy: DataStrategy {

    public func createHTTPBody(from object: Any) -> Data? {
        return try? JSONSerialization.data(withJSONObject: object)
    }

}
