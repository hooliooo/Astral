//  The MIT License (MIT)

//  Copyright © 2017 Julio Alorro

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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
                fatalError("Not a Dictionary value")
        }
    }
}
