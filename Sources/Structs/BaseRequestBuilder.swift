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
    private var _strategy: DataStrategy

}

// MARK: - RequestBuilder Protocol
extension BaseRequestBuilder: RequestBuilder {

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

        let hasNoHTTPBody: Bool = request.parameters.isEmpty || request.isGetRequest

        switch hasNoHTTPBody {
            case true:
                return nil

            case false:
                return self._strategy.createHTTPBody(from: request.parameters)
        }
    }

}
