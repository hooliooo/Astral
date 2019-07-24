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

    /**
     Creates and executes a URLSessionDataTask with an onComplete callback that returns a Result.
     Returns the URLSessionDataTask created.
     - parameter request:    The URLRequest used to create an HTTP networking request.
     - parameter onComplete: The callback that is executed when the URLSessionDataTask returns with a success or failure.
     - parameter result:     The result of the URLSessionDataTask. Either a success or failure.
    */
    @discardableResult
    open func response(of request: URLRequest, onComplete: @escaping (_ result: Result<Response, NetworkingError>) -> Void) -> URLSessionDataTask {
        // swiftlint:disable:previous function_body_length
        let logger: OSLog = Astral.shared.logger

        os_log("URL: %@", log: logger, type: OSLogType.info, request.url?.absoluteString ?? "No URL")
        os_log("HTTP Method: %@", log: logger, type: OSLogType.info, request.httpMethod ?? "No HTTP Method")
        os_log("HTTP Headers", log: logger, type: OSLogType.info)

        if let headers = request.allHTTPHeaderFields {
            for header in headers {
                os_log("HTTP Header: %@ => %@", log: Astral.shared.logger, type: OSLogType.info, header.key, header.value)
            }
        }

        let body: String = {
            if let body = request.httpBody {
                if let value = String(data: body, encoding: String.Encoding.utf8) {
                    return value
                } else {
                    return body.description
                }
            } else {
                return "No body"
            }
        }()

        os_log("Body: %s", log: logger, type: OSLogType.info, body)

        let task: URLSessionDataTask = self.session.dataTask(with: request) {
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
     Creates and executes a URLSessionDataTask with an onComplete callback that returns a Result.
     Returns the URLSessionDataTask created.
     - parameter url:        The URL instance used to build the URLRequest.
     - parameter onComplete: The callback that is executed when the URLSessionDataTask returns with a success or failure.
     - parameter result:     The result of the URLSessionDataTask. Either a success or failure.
     */
    @discardableResult
    open func response(of url: URL, onComplete: @escaping (_ result: Result<Response, NetworkingError>) -> Void) -> URLSessionDataTask {
        let urlRequest: URLRequest = URLRequest(url: url)
        return self.response(of: urlRequest, onComplete: onComplete)
    }

    /**
     Creates and executes a URLSessionDataTask with an onComplete callback that returns a Result.
     Returns the URLSessionDataTask created.
     - parameter request:    The Request instance used to build the URLRequest from the RequestBuilder.
     - parameter onComplete: The callback that is executed when the URLSessionDataTask returns with a success or failure.
     - parameter result:     The result of the URLSessionDataTask. Either a success or failure.
     */
    @discardableResult
    open func response(of request: Request, onComplete: @escaping (_ result: Result<Response, NetworkingError>) -> Void) -> URLSessionDataTask {
        let urlRequest: URLRequest = self.builder.urlRequest(of: request)
        return self.response(of: urlRequest, onComplete: onComplete)
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
    open func multipartFormDataResponse( // swiftlint:disable:this function_body_length
        of request: MultiPartFormDataRequest,
        onComplete: @escaping (_ result: Result<Response, NetworkingError>) -> Void
    ) throws -> URLSessionDataTask {
        guard let builder = self.builder as? MultiPartFormDataBuilder else {
            throw BaseRequestDispatcher.Error.builder("RequestBuilder instance is not a MultiPartFormDataBuilder")
        }

        let method: String = request.method.stringValue

        let urlRequest: URLRequest = try builder.multipartFormDataURLRequest(of: request)
        let logger: OSLog = Astral.shared.logger

        os_log("URL: %@", log: logger, type: OSLogType.info, urlRequest.url?.absoluteString ?? "No URL")
        os_log("HTTP Method: %@", log: logger, type: OSLogType.info, method)
        os_log("HTTP Headers", log: logger, type: OSLogType.info)

        if let headers = urlRequest.allHTTPHeaderFields {
            for header in headers {
                os_log("HTTP Header: %@ => %@", log: Astral.shared.logger, type: OSLogType.info, header.key, header.value)
            }
        }

        os_log("Parameters %@", log: logger, type: OSLogType.info, request.parameters.description)
        let fileURL: URL = builder.fileManager.ast.fileURL(of: request)
        os_log("File URL of file to upload %@", log: logger, type: OSLogType.info, fileURL.absoluteString)

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

                        do {
                            try builder.fileManager.removeItem(at: fileURL)
                        } catch let error {
                            os_log(
                                "Could not remove file after upload => %{public}@",
                                log: Astral.shared.logger,
                                type: OSLogType.error,
                                error.localizedDescription
                            )
                        }

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
}
