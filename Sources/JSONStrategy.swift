//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.Data
import class Foundation.JSONSerialization

/**
 An implementation of DataStrategy that is suited for a Content-Type of application/json for the body of an
 http request.
*/
public struct JSONStrategy: DataStrategy {

    // MARK: Initializer
    public init() {}

    // MARK: Instance Methods
    public func createHTTPBody(from request: Request) -> Data? {

        switch request.parameters {
            case .dict(let dict):
                return try? JSONSerialization.data(withJSONObject: dict)

            case .array(let array):
                return try? JSONSerialization.data(withJSONObject: array)

            case .none:
                return nil

        }

    }

}
