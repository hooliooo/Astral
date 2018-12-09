//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.Data
import struct Foundation.URLRequest

/**
 An implementation of RequestBuilder that can build URLRequests for simple http network requests.
*/
public struct BaseHTTPBodyBuilder {

    // MARK: Stored Properties
    private var _strategy: HTTPBodyStrategy

}

// MARK: - RequestBuilder Protocol
extension BaseHTTPBodyBuilder: RequestBuilder, HTTPBodyBuilder {

    // MARK: Initializer
    public init(strategy: HTTPBodyStrategy) {
        self._strategy = strategy
    }

    // MARK: Getter/Setter Properties
    public var strategy: HTTPBodyStrategy {
        get { return self._strategy }

        set { self._strategy = newValue }
    }

    // MARK: Instance Methods
    public func httpBody(of request: Request) -> Data? {

        let hasNoHTTPBody: Bool =  request.isGetRequest

        switch hasNoHTTPBody {
            case true:
                return nil

            case false:
                return self._strategy.createHTTPBody(from: request.parameters)
        }
    }

    public func urlRequest(of request: Request) -> URLRequest {
        var urlRequest: URLRequest = self._urlRequest(of: request)
        urlRequest.httpBody = self.httpBody(of: request)
        return urlRequest
    }

}
