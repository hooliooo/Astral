//
//  JSONType.swift
//  Pods
//
//  Created by Julio Alorro on 6/20/17.
//
//

import Foundation

public enum JSON {
    case array([[String: Any]])
    case dictionary([String: Any])

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

    public var arrayValue: [[String: Any]] {
        switch self {
            case .array(let array):
                return array

            case .dictionary:
                fatalError("Not an Array value")
        }
    }

    public var dictValue: [String: Any] {
        switch self {
            case .dictionary(let dict):
                return dict

            case .array:
                fatalError("Not an Dictionary value")
        }
    }
}
