//
//  Astral
//  Copyright © 2017 Julio Alorro
//  Licensed under the MIT license. See LICENSE file
//

import BrightFutures
import Result

public typealias httpRequestResult = (Result<Response, NetworkingError>) -> Void

/**
 An implementation of RequestSender that uses the URLSession shared instance for http network requests.
*/
public struct JSONRequestSender<T: RequestBuilder> {

    // MARK: Stored Properties
    fileprivate let _requestBuilder: RequestBuilder
    fileprivate let _printsResponse: Bool
}

extension JSONRequestSender: RequestSender {

    public init(request: Request, printsResponse: Bool) {
        self.init(builder: T(request: request), printsResponse: printsResponse)
    }

    public init(builder: RequestBuilder, printsResponse: Bool) {
        self._printsResponse = printsResponse
        self._requestBuilder = builder
    }

    public var request: Request {
        return self._requestBuilder.request
    }

    public var urlRequest: URLRequest {
        return self._requestBuilder.urlRequest
    }

    public var printsResponse: Bool {
        return self._printsResponse
    }

    public func sendURLRequest() -> Future<Response, NetworkingError> {

        return Future { (callback: @escaping httpRequestResult) -> Void in
            let task: URLSessionDataTask = URLSession.shared.dataTask(with: self.urlRequest) {
                (data: Data?, response: URLResponse?, error: Error?) in // swiftlint:disable:this closure_parameter_position

                if let error = error {

                    callback(Result.failure(NetworkingError.connection(error.localizedDescription)))

                } else if let data = data, let response = response as? HTTPURLResponse {

                    switch self._printsResponse {
                        case true:
                            print("httpResponse: \(response)")

                        case false:
                            break
                    }

                    switch response.statusCode {

                        case 200...399:

                            callback(Result.success(JSONResponse(httpResponse: response, data: data)))

                        case 400...599:

                            if let errorResponse = String(data: data, encoding: String.Encoding.utf8) {

                                callback(Result.failure(NetworkingError.response(errorResponse)))

                            } else {

                                callback(Result.failure(NetworkingError.response("Error could not be transformed into string")))

                            }

                        default:
                            fatalError("Unhandled status code: \(response.statusCode)")
                    }
                }
            }

            task.resume()
        }
    }

    public func cancelURLRequest() {
        URLSession.shared.getAllTasks { (tasks: [URLSessionTask]) -> Void in

            guard
                let task = tasks.filter({ $0.currentRequest == self.urlRequest }).first
            else { return }

            task.cancel()

        }
    }
}
