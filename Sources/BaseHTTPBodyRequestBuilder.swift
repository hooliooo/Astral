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
public struct BaseHTTPBodyRequestBuilder {

    // MARK: Stored Properties
    private var _strategy: DataStrategy

}

// MARK: - RequestBuilder Protocol
extension BaseHTTPBodyRequestBuilder: RequestBuilder, HTTPBodyRequestBuilder {

    // MARK: Initializer
    public init(strategy: DataStrategy) {
        self._strategy = strategy
    }

    // MARK: Getter/Setter Properties
    public var strategy: DataStrategy {
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
                return self._strategy.createHTTPBody(from: request)
        }
    }

    public func urlRequest(of request: Request) -> URLRequest {
        var urlRequest: URLRequest = self._urlRequest(of: request)
        urlRequest.httpBody = self.httpBody(of: request)
        return urlRequest
    }

}
