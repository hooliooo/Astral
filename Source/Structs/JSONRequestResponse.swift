//
//  JSONResponse.swift
//  Pods
//
//  Created by Julio Alorro on 6/20/17.
//
//

import Foundation

public struct JSONRequestResponse {
    let _statusCode: Int
    let _response: JSON
}

extension JSONRequestResponse: RequestResponse {

    public init(httpResponse: HTTPURLResponse, data: Data) {
        self._statusCode = httpResponse.statusCode
        self._response = JSON(data: data)
    }

    public var statusCode: Int {
        return self._statusCode
    }

    public var payload: JSON {
        return self._response
    }

}
