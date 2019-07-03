//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.DispatchQueue
import class Foundation.URLSessionDataTask
import struct Foundation.URLRequest
import class Foundation.URLResponse
import class Foundation.HTTPURLResponse
import struct Foundation.Data
import struct Foundation.URL
import class Foundation.NSNumber
import struct Foundation.FileAttributeKey
import protocol Foundation.LocalizedError
import os

/**
 A subclass of AstralRequestDispatcher that executes a URLSession's dataTask(with request:completionHandler:) method.
 This class is usually enough for a basic HTTP requests.
*/
open class BaseRequestDispatcher: AstralRequestDispatcher {

    // MARK: Enums
    /**
     Errors associated with methods of BaseRequestDispatcher
    */
    public enum Error: LocalizedError, CustomStringConvertible {
        /**
         The RequestBuilder is not a MultiPartFormDataBuilder
        */
        case builder(String)

        public var localizedDescription: String {
            switch self {
                case .builder(let string):
                    return string
            }
        }

        public var errorDescription: String? {
            return self.localizedDescription
        }

        public var failureReason: String? {
            return self.localizedDescription
        }

        public var description: String {
            return self.localizedDescription
        }
    }

    // MARK: Initializer
    public convenience init(strategy: DataStrategy, isDebugMode: Bool = true) {
        self.init(builder: BaseHTTPBodyRequestBuilder(strategy: strategy), isDebugMode: isDebugMode)
    }

    public convenience init(isDebugMode: Bool = true) {
        self.init(builder: BaseHTTPBodyRequestBuilder(strategy: JSONStrategy()), isDebugMode: isDebugMode)
    }

    @discardableResult
    open func response(of request: Request, onComplete: @escaping (Result<Response, NetworkingError>) -> Void) -> URLSessionDataTask {
        let method: String = request.method.stringValue

        let urlRequest: URLRequest = self.builder.urlRequest(of: request)
        let logger: OSLog = Astral.shared.logger

        os_log("URL: %@", log: logger, type: OSLogType.info, urlRequest.url?.absoluteString ?? "No URL")
        os_log("HTTP Method: %@", log: logger, type: OSLogType.info, method)
        os_log("HTTP Headers", log: logger, type: OSLogType.info)

        if let headers = urlRequest.allHTTPHeaderFields {
            for header in headers {
                os_log("HTTP Header: %@ => %@", log: Astral.shared.logger, type: OSLogType.info, header.key, header.value)
            }
        }

        os_log("Parameters", log: logger, type: OSLogType.info, request.parameters.description)

        let task: URLSessionDataTask = self.session.dataTask(with: urlRequest) {
            (data: Data?, response: URLResponse?, error: Swift.Error?) -> Void in
            // swiftlint:disable:previous closure_parameter_position

            if let error = error {

                onComplete(Result<Response, NetworkingError>.failure(NetworkingError.connection(error)))

            } else if let data = data, let response = response as? HTTPURLResponse {

                let jsonResponse: JSONResponse = JSONResponse(httpResponse: response, data: data)

                switch response.statusCode {
                    case 200...399:

                        os_log("Successful Response: %@", log: logger, type: OSLogType.info, jsonResponse.description)

                        onComplete(Result<Response, NetworkingError>.success(jsonResponse))

                    case 400...599:
                        os_log("Error Response: %@", log: logger, type: OSLogType.error, jsonResponse.description)
                        onComplete(Result<Response, NetworkingError>.failure(NetworkingError.response(jsonResponse)))

                    default:
                        os_log("Unhandled Response: %@", log: logger, type: OSLogType.error, jsonResponse.description)
                        onComplete(
                            Result<Response, NetworkingError>.failure(
                                NetworkingError.unknownResponse(
                                    jsonResponse,
                                    "Unhandled status code: \(response.statusCode)"
                                )
                            )
                        )
                }

            } else {
                os_log("Unknown response", log: logger, type: OSLogType.error)
                onComplete(Result<Response, NetworkingError>.failure(NetworkingError.unknown("Unknown error occured")))
            }
        }

        task.resume()

        return task
    }

    /**
     Creates and executes a URLSessionDataTask with onSuccess, onFailure, and onComplete completion handlers.
     Returns the URLSessionDataTask created.
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
        let method: String = request.method.stringValue

        let urlRequest: URLRequest = self.builder.urlRequest(of: request)
        let logger: OSLog = Astral.shared.logger

        os_log("URL: %@", log: logger, type: OSLogType.info, urlRequest.url?.absoluteString ?? "No URL")
        os_log("HTTP Method: %@", log: logger, type: OSLogType.info, method)
        os_log("HTTP Headers", log: logger, type: OSLogType.info)

        if let headers = urlRequest.allHTTPHeaderFields {
            for header in headers {
                os_log("HTTP Header: %@ => %@", log: Astral.shared.logger, type: OSLogType.info, header.key, header.value)
            }
        }

        os_log("Parameters", log: logger, type: OSLogType.info, request.parameters.description)

        let task: URLSessionDataTask = self.session.dataTask(with: urlRequest) {
            (data: Data?, response: URLResponse?, error: Swift.Error?) -> Void in
            // swiftlint:disable:previous closure_parameter_position

            onComplete()

            if let error = error {

                onFailure(
                    NetworkingError.connection(error)
                )

            } else if let data = data, let response = response as? HTTPURLResponse {

                let json: JSONResponse = JSONResponse(httpResponse: response, data: data)

                switch response.statusCode {
                    case 200...399:

                        os_log("Successful Response: %@", log: logger, type: OSLogType.info, json.description)

                        onSuccess(json)

                    case 400...599:
                        os_log("Error Response: %@", log: logger, type: OSLogType.error, json.description)
                        onFailure(NetworkingError.response(json))

                    default:
                        os_log("Unhandled Response: %@", log: logger, type: OSLogType.error, json.description)
                        onFailure(
                            NetworkingError.unknownResponse(
                                json,
                                "Unhandled status code: \(response.statusCode)"
                            )
                        )
                }

            } else {
                os_log("Unknown response", log: logger, type: OSLogType.error)
                onFailure(NetworkingError.unknown("Unknown error occured"))

            }
        }

        task.resume()

        return task
    }

    /**
     Creates and executes a URLSessionDataTask with onSuccess, onFailure, and onComplete completion handlers.
     Use specifically for multipart form data requests. Can throw an error.
     Returns the URLSessionDataTask created.
     - parameter request:    The MultipartFormDataRequest instance used to build the URLRequest from the RequestBuilder.
     - parameter onSuccess:  The callback that is executed when the completion handler returns valid Data.
     - parameter response:   The Data from the completion handler transformed as a Response.
     - parameter onFailure:  The callback that is executed when the completion handler return an Error.
     - parameter error:      The Error from the completion handler transformed as a NetworkingError.
     - parameter onComplete: The callback that is executed when the completion handler returns either Data or en Error.
     */
    @discardableResult
    open func multipartFormDataResponse(
        of request: MultiPartFormDataRequest,
        onSuccess: @escaping (_ response: Response) -> Void,
        onFailure: @escaping (_ error: NetworkingError) -> Void,
        onComplete: @escaping () -> Void
    ) throws -> URLSessionDataTask {
        guard let builder = self.builder as? MultiPartFormDataBuilder else {
            throw BaseRequestDispatcher.Error.builder("RequestBuilder instance is not a MultiPartFormDataBuilder")
        }

        let isDebugMode: Bool = self.isDebugMode
        let method: String = request.method.stringValue

        let urlRequest: URLRequest = try builder.multipartFormDataURLRequest(of: request)
        let fileURL: URL = builder.fileManager.ast.fileURL(of: request)

        let task: URLSessionDataTask = self.session.dataTask(with: urlRequest) {
            (data: Data?, response: URLResponse?, error: Swift.Error?) -> Void in
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
                        dump("URLRequest: \(urlRequest)")
                        print("Response: \(response)")

                    case false:
                        break
                }

                switch response.statusCode {
                    case 200...399:
                        onSuccess(
                            JSONResponse(httpResponse: response, data: data)
                        )

                        try? builder.fileManager.removeItem(at: fileURL)

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
