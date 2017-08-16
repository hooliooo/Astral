//
//  FormURLEncodedStrategy.swift
//  Astral
//
//  Created by Julio Alorro on 8/16/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

public struct FormURLEncodedStrategy {

    // MARK: Static Properties
    fileprivate let characterSet: CharacterSet = {
        var set: CharacterSet = CharacterSet.alphanumerics
        set.insert(charactersIn: "-._* ")
        return set
    }()

    // MARK: Instance Methods
    fileprivate func percentEscaped(string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: self.characterSet)!
            .replacingOccurrences(of: " ", with: "+")
    }

}

extension FormURLEncodedStrategy: DataStrategy {

    public func createHTTPBody(from object: Any) -> Data? {
        if let parametersDict = object as? [String: String] {
            let parameters: [String] = parametersDict.map { (dict: (key: String, value: String)) -> String in
                return "\(dict.key)=\(self.percentEscaped(string: dict.value))"
            }

            let parameterString: String = parameters.joined(separator: "&")

            return parameterString.data(using: String.Encoding.utf8)
        } else {
            return nil
        }
    }

}
