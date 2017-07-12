//
//  Astral
//  Copyright © 2017 Julio Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

public struct JSONRequestResponse {
    fileprivate let _statusCode: Int
    fileprivate let _data: Data
    fileprivate let _response: JSON
}

extension JSONRequestResponse: RequestResponse {

    public init(httpResponse: HTTPURLResponse, data: Data) {
        self._statusCode = httpResponse.statusCode
        self._data = data
        self._response = JSON(data: data)
    }

    public var statusCode: Int {
        return self._statusCode
    }

    public var data: Data {
        return self._data
    }

    public var payload: JSON {
        return self._response
    }

}
