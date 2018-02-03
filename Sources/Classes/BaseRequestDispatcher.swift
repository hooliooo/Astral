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
open class BaseRequestDispatcher {

    // MARK: Intializers
    /**
     Initializer with a Request and a RequestBuilder type.
     - parameter request: The Request instance used to build a URLRequest in the RequestBuilder.

     - parameter builderType: The type of RequestBuilder that will be initialized to create the URLRequest.

       Default value is BaseRequestBuilder.

     - parameter strategy: The DataStrategy used to create the body of the http request.

       Default value is JSONStrategy.

     - parameter isDebugMode: Indicates whether the HTTPURLResponse will be printed to the console or not.

       Default value is true.
    */
    public convenience required init(
        request: Request,
        builderType: RequestBuilder.Type = BaseRequestBuilder.self,
        strategy: DataStrategy = JSONStrategy(),
        isDebugMode: Bool = true
    ) {
        self.init(
            builder: builderType.init(request: request, strategy: strategy),
            isDebugMode: isDebugMode
        )
    }

    public required init(builder: RequestBuilder, isDebugMode: Bool) {
        self._requestBuilder = builder
        self._isDebugMode = isDebugMode
    }

    deinit {
        switch self._isDebugMode {
            case true:
                print("\(type(of: self)) was deallocated")

            case false:
                break
        }
    }

    // MARK: Stored Properties
    private var _requestBuilder: RequestBuilder
    private let _isDebugMode: Bool
    private var _tasks: [URLSessionTask] = []

    // MARK: Static Properties
    open class var session: URLSession {
        return URLSession.shared
    }

}

extension BaseRequestDispatcher: RequestDispatcher {

    // MARK: Getter/Setter Properties
    open var request: Request {
        get { return self._requestBuilder.request }

        set { self._requestBuilder.request = newValue }
    }

    open var builder: RequestBuilder {
        get { return self._requestBuilder }

        set { self._requestBuilder = newValue }
    }

    open var urlRequest: URLRequest {
        return self._requestBuilder.urlRequest
    }

    open var isDebugMode: Bool {
        return self._isDebugMode
    }

    open var tasks: [URLSessionTask] {
        return self._tasks
    }

    open func response() -> Future<Response, NetworkingError> {

        self._tasks = self._tasks.filter { $0.state != URLSessionTask.State.running }

        let isDebugMode: Bool = self._isDebugMode
        let method: String = self.request.method.stringValue
        let urlRequest: URLRequest = self.urlRequest

        return Future(resolver: { [weak self] (callback: @escaping HTTPRequestResult) -> Void in

            let task: URLSessionDataTask = BaseRequestDispatcher.session.dataTask(with: urlRequest) {
                (data: Data?, response: URLResponse?, error: Error?) -> Void in
                // swiftlint:disable:previous closure_parameter_position

                if let error = error {

                    callback(
                        Result.failure(
                            NetworkingError.connection(error)
                        )
                    )

                } else if let data = data, let response = response as? HTTPURLResponse {

                    switch isDebugMode {
                        case true:
                            print("HTTP Method: \(method)")
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
                                    NetworkingError.unknownResponse(
                                        JSONResponse(httpResponse: response, data: data),
                                        "Unhandled status code: \(response.statusCode)"
                                    )
                                )
                            )
                    }
                } else {

                    callback(
                        Result.failure(
                            NetworkingError.unknown("Unknown error occured")
                        )
                    )

                }
            }

            task.resume()

            self?._tasks.append(task)
        })
    }

    open func cancel() {
        for task in self._tasks {
            task.cancel()
        }

        self._tasks = []
    }
}
