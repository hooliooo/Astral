//
//  Astral
//  Copyright © 2017 Julio Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation
/**
 The JSON enum represents the data from an http response as either an array of dictionaries or a single dictionary
*/
public enum JSON {
    case array([[String: Any]])
    case dictionary([String: Any])

    /**
     The initializer of a JSON enum
    */
    public init(data: Data) {
        guard let json = try? JSONSerialization.jsonObject(with: data)
            else { fatalError("Could not turn data into a JSON") }

        switch json {
            case let jsonDict as [String: Any]:
                self = JSON.dictionary(jsonDict)

            case let jsonArray as [[String: Any]]:
                self = JSON.array(jsonArray)

            default:
                fatalError("Not a valid JSON")
        }
    }

    /**
     Returns the array of the .array case, otherwise induces a fatalError
    */
    public var arrayValue: [[String: Any]] {
        switch self {
            case .array(let array):
                return array

            case .dictionary:
                fatalError("Not an Array value")
        }
    }

    /**
     Returns the dictionary of the .dictionary case, otherwise induces a fatalError
    */
    public var dictValue: [String: Any] {
        switch self {
            case .dictionary(let dict):
                return dict

            case .array:
                fatalError("Not a Dictionary value")
        }
    }
}
