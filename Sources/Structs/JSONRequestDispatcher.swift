//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation
import BrightFutures
import Result

public typealias HTTPRequestResult = (Result<Response, NetworkingError>) -> Void

/**
 An implementation of RequestDispatcher that uses the URLSession shared instance for http network requests.
*/
open class JSONRequestDispatcher {

    // MARK: Intializers
    public convenience required init(
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

    public required init(builder: RequestBuilder, printsResponse: Bool) {
        self._requestBuilder = builder
        self._printsResponse = printsResponse
    }

    // MARK: Stored Properties
    private var _requestBuilder: RequestBuilder
    private let _printsResponse: Bool
    private var _tasks: [URLSessionTask] = []

    // MARK: Static Properties
    public static let session: URLSession = URLSession.shared

}

extension JSONRequestDispatcher: RequestDispatcher {

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

    public var tasks: [URLSessionTask] {
        return self._tasks
    }

    public func response() -> Future<Response, NetworkingError> {
            return Future(resolver: { [weak self] (callback: @escaping HTTPRequestResult) -> Void in
                guard let `self` = self else { return }
                let task: URLSessionDataTask = JSONRequestDispatcher.session.dataTask(with: self.urlRequest) {
                    [weak self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
                    // swiftlint:disable:previous closure_parameter_position
                    guard let `self` = self else { return }
                    if let error = error {

                        callback(
                            Result.failure(
                                NetworkingError.connection(error)
                            )
                        )

                    } else if let data = data, let response = response as? HTTPURLResponse {

                        switch self.printsResponse {
                            case true:
                                print("HTTP Method: \(self.request.method.stringValue)")
                                print("Response: \(response)")

                            case false:
                                break
                        }

                        switch response.statusCode {
                            case 200...399:
                                callback(
                                    Result.success(
                                        JSONResponse(httpResponse: response, data: data)
                                    )
                                )

                            case 400...599:
                                callback(
                                    Result.failure(
                                        NetworkingError.response(
                                            JSONResponse(httpResponse: response, data: data)
                                        )
                                    )
                                )

                            default:
                                callback(
                                    Result.failure(
                                        NetworkingError.unknown(
                                            JSONResponse(httpResponse: response, data: data),
                                            "Unhandled status code: \(response.statusCode)"
                                        )
                                    )
                                )
                        }
                    }
                }

                task.resume()

                self._tasks.append(task)
            })
    }

    public func cancel() {
        for task in self._tasks {
            task.cancel()
        }

        self._tasks = []
    }
}
