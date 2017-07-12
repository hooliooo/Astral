//
//  Astral
//  Copyright © 2017 Julio Alorro
//  Licensed under the MIT license. See LICENSE file
//

/**
 An Enum that represents errors related to HTTP network requests
*/
public enum NetworkingError: Error {
    case invalidRequest(String)
    case connection(String)
    case response(String)

    var localizedDescription: String {
        switch self {
            case .invalidRequest(let parameter):
                return parameter

            case .connection(let string):
                return string

            case .response(let string):
                return string
        }
    }

    var title: String {
        switch self {
            case .invalidRequest:
                return "Invalid Request"

            case .connection:
                return "Connection Error"

            case .response:
                return "Response Error"
        }
    }
}
