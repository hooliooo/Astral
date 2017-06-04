//  The MIT License (MIT)

//  Copyright (c) 2017 Julio Alorro

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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
        return Future { (callback: @escaping (Result<Data, NetworkingError>) -> Void) -> Void in
            let task: URLSessionDataTask = URLSession.shared.dataTask(with: self.urlRequest) {
                (data: Data?, response: URLResponse?, error: Error?) in // swiftlint:disable:this closure_parameter_position

                if let error = error {

                    callback(Result.failure(NetworkingError.connection(error.localizedDescription)))

                } else if let data = data, let response = response as? HTTPURLResponse {

                    switch self._printsResponse {
                        case true:
                            print("HTTPResponse \(response)")

                        case false:
                            break
                    }

                    switch response.statusCode {

                        case 400...599:

                            if let errorResponse = String(data: data, encoding: String.Encoding.utf8) {

                                callback(Result.failure(NetworkingError.response(errorResponse)))

                            } else {

                                callback(Result.failure(NetworkingError.response("Error could not be transformed into string")))

                            }

                        case 200...399:

                            callback(Result.success(data))
                        
                        default:
                            fatalError("Unhandled status code: \(response.statusCode)")
                        
                    }
                }
            }
            
            task.resume()
        }
    }
}
