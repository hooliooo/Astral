//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 An implementation of Response that represents the data from an HTTPURLResponse.
*/
public struct JSONResponse {

    // MARK: Stored Properties
    private let _statusCode: Int
    private let _data: Data
    private let _json: JSON
}

extension JSONResponse: Response {

    // MARK: Initializer
    public init(httpResponse: HTTPURLResponse, data: Data) {
        self._statusCode = httpResponse.statusCode
        self._data = data
        self._json = JSON(data: data)
    }

    // MARK: Computed Properties
    public var statusCode: Int {
        return self._statusCode
    }

    public var data: Data {
        return self._data
    }

    public var json: JSON {
        return self._json
    }

}
