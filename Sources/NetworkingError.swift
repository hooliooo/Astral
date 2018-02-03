//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

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
        switch self {
            case .connection(let error):
                return error.localizedDescription

            case .response(let response):
                return response.json.description

            case .unknownResponse(let response, let text):
                return "\(text)\n\n\(response)"

            case .unknown(let text):
                return text
        }
    }

    public var localizedDescription: String {
        return self.errorDescription!
    }

    public var failureReason: String? {
        return self.errorDescription
    }
}
