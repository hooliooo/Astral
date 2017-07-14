//
//  Astral
//  Copyright © 2017 Julio Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation
/**
 An implementation of Response that represents the data from an HTTPURLResponse.
*/
public struct JSONResponse {

    // MARK: Stored Properties
    fileprivate let _statusCode: Int
    fileprivate let _data: Data
    fileprivate let _response: JSON
}

extension JSONResponse: Response {

    // MARK: Initializer
    public init(httpResponse: HTTPURLResponse, data: Data) {
        self._statusCode = httpResponse.statusCode
        self._data = data
        self._response = JSON(data: data)
    }

    // MARK: Computed Properties
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
