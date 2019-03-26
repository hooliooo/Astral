//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import protocol Foundation.LocalizedError

/**
 An Enum that represents errors related to http network requests
*/
public enum NetworkingError: LocalizedError {
    /**
     Connection error
    */
    case connection(Error)

    /**
     Response error
    */
    case response(Response)

    /**
     Unknown Response error
    */
    case unknownResponse(Response, String)

    /**
     Unknown Error
    */
    case unknown(String)

    public var errorDescription: String? {
        return self.localizedDescription
    }

    public var localizedDescription: String {
        switch self {
            case .connection(let error):
                return error.localizedDescription

            case .response(let response):
                return response.json.description

            case let .unknownResponse(response, text):
                return "\(text)\n\n\(response)"

            case .unknown(let text):
                return text
        }
    }

    public var failureReason: String? {
        return self.localizedDescription
    }
}
