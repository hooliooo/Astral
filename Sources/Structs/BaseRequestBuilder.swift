//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 An implementation of RequestBuilder that can build URLRequests for simple http network requests.
*/
public struct BaseRequestBuilder {

    // MARK: Stored Properties
    private var _request: Request
    private var _strategy: DataStrategy

}

// MARK: - RequestBuilder Protocol
extension BaseRequestBuilder: RequestBuilder {

    // MARK: Initializer
    public init(request: Request, strategy: DataStrategy) {
        self._request = request
        self._strategy = strategy
    }

    // MARK: Getter/Setter Properties
    public var request: Request {
        get { return self._request }

        set { self._request = newValue }
    }

    public var strategy: DataStrategy {
        get { return self._strategy }

        set { self._strategy = newValue }
    }

    // MARK: Computed Properties
    public var httpBody: Data? {

        let hasNoHTTPBody: Bool = self._request.parameters.isEmpty || self._request.isGetRequest

        switch hasNoHTTPBody {
            case true:
                return nil

            case false:
                return self._strategy.createHTTPBody(from: self.request.parameters)
        }
    }

}
