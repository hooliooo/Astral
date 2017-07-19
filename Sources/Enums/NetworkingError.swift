//
//  Astral
//  Copyright © 2017 Julio Alorro
//  Licensed under the MIT license. See LICENSE file
//

/**
 An Enum that represents errors related to http network requests
*/
public enum NetworkingError: Error {
    /**
     Connection error
    */
    case connection(String)
    /**
     Response error
    */
    case response(Response)

    var localizedDescription: String {
        switch self {
            case .connection(let string):
                return string

            case .response(let response):
                return response.payload.description
        }
    }
}
