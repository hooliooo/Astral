//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 An implementation of DataStrategy that is suited for a Content-Type of application/json for the body of an http request.
 When using this strategy and your httpBody is supposed to be an array of JSON objects, make sure the parameters of your Request object has only
 ONE key-value pair in the dictionary. Otherwise the createHTTPBody method will induce a crash.
*/
public struct JSONStrategy: DataStrategy {

    // MARK: Initializer
    public init () {}

    // MARK: Instance Methods
    public func createHTTPBody(from parameters: Parameters) -> Data? {

        switch parameters {
            case .dict(let dict):
                return try? JSONSerialization.data(withJSONObject: dict)

            case .array(let array):
                return try? JSONSerialization.data(withJSONObject: array)

            case .none:
                return nil

        }

    }

}
