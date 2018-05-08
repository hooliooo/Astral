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

    // MARK: Enum
    public enum Kind {
        case dict
        case array
    }

    // MARK: Initializer
    public init(kind: JSONStrategy.Kind) {
        self.kind = kind
    }

    // MARK: Stored Properties
    public let kind: JSONStrategy.Kind

    // MARK: Instance Methods
    public func createHTTPBody(from dict: [String: Any]) -> Data? {

        switch self.kind {
            case .dict:
                return try? JSONSerialization.data(withJSONObject: dict)

            case .array:
                switch dict.count == 1 {
                    case true:
                        return try? JSONSerialization.data(withJSONObject: dict.values.first!)

                    case false:
                        fatalError("You specified array but your dictionary contains more than one key-value pair")
                }
        }

    }

}
