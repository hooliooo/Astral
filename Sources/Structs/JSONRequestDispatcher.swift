//
//  Astral
//  Copyright (c) 2017 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation
import BrightFutures
import Result

public typealias HTTPRequestResult = (Result<Response, NetworkingError>) -> Void

/**
 An implementation of RequestDispatcher that uses the URLSession shared instance for http network requests.
*/
public struct JSONRequestDispatcher {

    // MARK: Stored Properties
    private var _requestBuilder: RequestBuilder
    private let _printsResponse: Bool

    // MARK: Static Properties
    public static let session: URLSession = URLSession.shared

}

extension JSONRequestDispatcher: RequestDispatcher {

    // MARK: Intializers
    public init(
        request: Request,
        builderType: RequestBuilder.Type = JSONRequestBuilder.self,
        strategy: DataStrategy = JSONStrategy(),
        printsResponse: Bool = true
    ) {
        self.init(
            builder: builderType.init(request: request, strategy: strategy),
            printsResponse: printsResponse
        )
    }

    public init(builder: RequestBuilder, printsResponse: Bool) {
        self._requestBuilder = builder
        self._printsResponse = printsResponse
    }

    // MARK: Getter/Setter Properties
    public var request: Request {
        get { return self._requestBuilder.request }

        set { self._requestBuilder.request = newValue }
    }

    public var builder: RequestBuilder {
        get { return self._requestBuilder }

        set { self._requestBuilder = newValue }
    }

    public var urlRequest: URLRequest {
        return self._requestBuilder.urlRequest
    }

    public var printsResponse: Bool {
        return self._printsResponse
    }
}
