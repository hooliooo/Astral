//
//  Astral
//  Copyright (c) 2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.DispatchQueue
import class Foundation.URLSessionDataTask
import struct Foundation.URLRequest
import class Foundation.URLResponse
import class Foundation.HTTPURLResponse
import struct Foundation.Data

open class BaseRequestDispatcher: AstralRequestDispatcher {

    // MARK: Intializer
    /**
     BaseRequestDispatcher is a subclass of AstralRequestDispatcher that uses callbacks to handle the asynchronous nature of networking.
     - parameter builder: The RequestBuilder used to create the URLRequest instance.
     - parameter isDebugMode: If true, the console will print out information related to the http networking request. If false, prints nothing.
     - parameter queue: The DispatchQueue that the callbacks will execute on.
    */
    public init(
        builder: RequestBuilder = BaseHTTPBodyBuilder(strategy: JSONStrategy()),
        isDebugMode: Bool = true,
        queue: DispatchQueue = DispatchQueue.main
    ) {
        self._queue = queue
        super.init(builder: builder, isDebugMode: isDebugMode)
    }

    public required init(builder: RequestBuilder, isDebugMode: Bool) {
        self._queue = DispatchQueue.main
        super.init(builder: builder, isDebugMode: isDebugMode)
    }

    public init(strategy: HTTPBodyStrategy, isDebugMode: Bool = true, queue: DispatchQueue = DispatchQueue.main) {
        self._queue = queue
        super.init(builder: BaseHTTPBodyBuilder(strategy: strategy), isDebugMode: isDebugMode)
    }

    // MARK: Stored Properties
    private let _queue: DispatchQueue

}

extension BaseRequestDispatcher: BaseDispatcher {
    open var queue: DispatchQueue {
        return self._queue
    }

    @discardableResult
    open func response(
        of request: Request,
        onSuccess: @escaping (_ response: Response) -> Void,
        onFailure: @escaping (_ error: NetworkingError) -> Void,
        onComplete: @escaping () -> Void
    ) -> URLSessionDataTask {
        let isDebugMode: Bool = self.isDebugMode
        let method: String = request.method.stringValue

        let urlRequest: URLRequest = self.builder.urlRequest(of: request)
        let queue: DispatchQueue = self.queue

        let task: URLSessionDataTask = self.session.dataTask(with: urlRequest) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            // swiftlint:disable:previous closure_parameter_position
            queue.async {

                onComplete()

                if let error = error {

                    onFailure(
                        NetworkingError.connection(error)
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
                            onSuccess(
                                JSONResponse(httpResponse: response, data: data)
                            )

                        case 400...599:
                            onFailure(
                                NetworkingError.response(
                                    JSONResponse(httpResponse: response, data: data)
                                )
                            )

                        default:
                            onFailure(
                                NetworkingError.unknownResponse(
                                    JSONResponse(httpResponse: response, data: data),
                                    "Unhandled status code: \(response.statusCode)"
                                )
                            )
                    }

                } else {

                    onFailure(
                        NetworkingError.unknown("Unknown error occured")
                    )

                }
            }
        }

        task.resume()

        return task
    }
}
