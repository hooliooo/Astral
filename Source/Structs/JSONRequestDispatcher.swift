//
//  Astral
//  Copyright © 2017 Julio Alorro
//  Licensed under the MIT license. See LICENSE file
//

import BrightFutures
import Result

public typealias HTTPRequestResult = (Result<Response, NetworkingError>) -> Void

/**
 An implementation of RequestDispatcher that uses the URLSession shared instance for http network requests.
*/
public struct JSONRequestDispatcher {

    // MARK: Stored Properties
    fileprivate let _requestBuilder: RequestBuilder
    fileprivate let _printsResponse: Bool

    // MARK: Static Properties
    public static let session: URLSession = URLSession.shared

}

extension JSONRequestDispatcher: RequestDispatcher {

    // MARK: Intializers
    public init(request: Request, builderType: RequestBuilder.Type, printsResponse: Bool) {
        self.init(builder: builderType.init(request: request), printsResponse: printsResponse)
    }

    public init(builder: RequestBuilder, printsResponse: Bool) {
        self._requestBuilder = builder
        self._printsResponse = printsResponse
    }

    // MARK: Computed Properties
    public var request: Request {
        return self._requestBuilder.request
    }

    public var urlRequest: URLRequest {
        return self._requestBuilder.urlRequest
    }

    public var printsResponse: Bool {
        return self._printsResponse
    }

    // MARK: Instance Methods
    public func dispatchURLRequest() -> Future<Response, NetworkingError> {

        return Future { (callback: @escaping HTTPRequestResult) -> Void in
            let task: URLSessionDataTask = JSONRequestDispatcher.session.dataTask(with: self.urlRequest) {
                (data: Data?, response: URLResponse?, error: Error?) in // swiftlint:disable:this closure_parameter_position

                if let error = error {

                    callback(
                        Result.failure(
                            NetworkingError.connection(
                                error.localizedDescription
                            )
                        )
                    )

                } else if let data = data, let response = response as? HTTPURLResponse {

                    switch self._printsResponse {
                        case true:
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
                            fatalError("Unhandled status code: \(response.statusCode)")
                    }
                }
            }

            task.resume()
        }
    }

    public func cancelURLRequest() {
        JSONRequestDispatcher.session.getAllTasks { (tasks: [URLSessionTask]) -> Void in

            guard
                let task = tasks.filter({
                    $0.currentRequest == self.urlRequest &&
                    $0.currentRequest?.httpBody == self.urlRequest.httpBody
                }).first
            else { return }

            task.cancel()

        }
    }
}
