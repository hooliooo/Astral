//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 An implementation of DataStrategy that is suited for a Content-Type of application/x-www-form-urlencoded for 
 the body of an http request
*/
public struct FormURLEncodedStrategy {

    // MARK: Static Properties
    private static let characterSet: CharacterSet = {
        var set: CharacterSet = CharacterSet.alphanumerics
        set.insert(charactersIn: "-._* ")
        return set
    }()

    // MARK: Initializer
    public init() {}

    // MARK: Instance Methods
    private func percentEscaped(string: String) -> String {
        return string
            .addingPercentEncoding(withAllowedCharacters: FormURLEncodedStrategy.characterSet)!
            .replacingOccurrences(of: " ", with: "+")
    }

    private func convert(dict: [String: Any]) -> [String: String]? {
        let bodyDict: [(String, String)] = dict.compactMap { (dict: (key: String, value: Any)) -> (String, String) in
            return (dict.key, String(describing: dict.value))
        }

        return bodyDict.reduce(into: [:]) { (result: inout [String: String], tuple: (key: String, value: String)) -> Void in
            result.updateValue(tuple.value, forKey: tuple.key)
        }
    }

}

extension FormURLEncodedStrategy: DataStrategy {

    public func createHTTPBody(from dict: [String: Any]) -> Data? {
        guard let parametersDict = self.convert(dict: dict) else { return nil }

        let parameters: [String] = parametersDict.map { (dict: (key: String, value: String)) -> String in
            return "\(dict.key)=\(self.percentEscaped(string: dict.value))"
        }

        let parameterString: String = parameters.joined(separator: "&")

        return parameterString.data(using: String.Encoding.utf8)
    }

}
