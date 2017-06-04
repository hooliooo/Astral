//
//  JSONRequestSender.swift
//  Astral
//
//  Created by Julio Alorro on 5/31/17.
//
//

import BrightFutures
import Result

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

    public func sendURLRequest() -> Future<Data, NetworkingError> {
        return Future { (complete: @escaping (Result<Data, NetworkingError>) -> Void) -> Void in
            let task: URLSessionDataTask = URLSession.shared.dataTask(with: self.urlRequest) {
                (data: Data?, response: URLResponse?, error: Error?) in // swiftlint:disable:this closure_parameter_position

                if let error = error {

                    complete(Result.failure(NetworkingError.connection(error.localizedDescription)))

                } else if let data = data, let response = response as? HTTPURLResponse {

                    switch self._printsResponse {
                        case true:
                            print(response)

                        case false:
                            break
                    }

                    switch response.statusCode {

                        case let statusCode where statusCode >= 400:

                            if let errorResponse = String(data: data, encoding: String.Encoding.utf8) {

                                complete(Result.failure(NetworkingError.response(errorResponse)))

                            } else {

                                complete(Result.failure(NetworkingError.response("Error could not be transformed into string")))

                            }

                        case let statusCode where statusCode >= 200 && statusCode < 300:

                            complete(Result.success(data))
                        
                        default:
                            fatalError("Unhandled status code: \(response.statusCode)")
                        
                    }
                }
            }
            
            task.resume()
        }
    }
}
