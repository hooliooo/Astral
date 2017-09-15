//
//  Astral
//  Copyright (c) 2017 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

/**
 An implementation of RequestBuilder that can build URLRequests for simple http network requests.
*/
public struct JSONRequestBuilder {

    // MARK: Stored Properties
    fileprivate var _request: Request
    fileprivate var _strategy: DataStrategy

}

// MARK: - RequestBuilder Protocol
extension JSONRequestBuilder: RequestBuilder {

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
        if self.request.parameters.isEmpty || self.request.isGetRequest {
            return nil
        }

        return self._strategy.createHTTPBody(from: self.request.parameters)
    }

}
