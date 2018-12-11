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

/**
 A subclass of AstralRequestDispatcher that executes a URLSession's dataTask(with request:completionHandler:) method.
 This class is usually enough for a basic HTTP requests.
*/
open class BaseRequestDispatcher: AstralRequestDispatcher {

    /**
     Creates and executes a URLSessionDataTask with onSuccess, onFailure, and onComplete completion handlers.
     Executed Asynchronously on the DispatchQueue. Returns the URLSessionDataTask created.
     - parameter request:    The Request instance used to build the URLRequest from the RequestBuilder.
     - parameter onSuccess:  The callback that is executed when the completion handler returns valid Data.
     - parameter response:   The Data from the completion handler transformed as a Response.
     - parameter onFailure:  The callback that is executed when the completion handler return an Error.
     - parameter error:      The Error from the completion handler transformed as a NetworkingError.
     - parameter onComplete: The callback that is executed when the completion handler returns either Data or en Error.
     */
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

        let task: URLSessionDataTask = self.session.dataTask(with: urlRequest) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            // swiftlint:disable:previous closure_parameter_position

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

        task.resume()

        return task
    }
}
