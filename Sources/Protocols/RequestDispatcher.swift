//
//  Astral
//  Copyright (c) 2017 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation
import BrightFutures
import Result

/**
 A RequestDispatcher uses the URLRequest of the RequestBuilder to make an
 http network request using the a URLSession instance.
*/
public protocol RequestDispatcher {
    /**
     The URLSession used for the RequestDispatcher type
    */
    static var session: URLSession { get }

    /**
     Initializer with a Request and RequestBuilder type
     - parameter request: The Request instance used to build a URLRequest in the RequestBuilder
     - parameter builderType: The type of RequestBuilder that will be initialized to create the URLRequest
     - parameter strategy: The DataStrategy used to create the body of the http request
     - parameter printsResponse: Indicates whether the HTTPURLResponse will be printed to the console or not
    */
    init(request: Request, builderType: RequestBuilder.Type, strategy: DataStrategy, printsResponse: Bool)

    /**
     Initializer using a RequestBuiler
     - parameter builder: The RequestBuilder instance used to build a URLRequest
     - parameter printsResponse: Indicates whether the HTTPURLResponse will be printed to the console or not
    */
    init(builder: RequestBuilder, printsResponse: Bool)

    /**
     The Request associated with the RequestDispatcher
    */
    var request: Request { get set }

    /**
     The Request Builder associated with the RequestDispatcher
    */
    var builder: RequestBuilder { get set }

    /**
     The URLRequest associated with the RequestDispatcher
    */
    var urlRequest: URLRequest { get }

    /**
     When set to true, the headers of the HTTPURLResponse is printed in the console log. Use for debugging purposes
    */
    var printsResponse: Bool { get }

    /**
     Creates the URLSessionDataTask from the URLRequest and transforms the data from the completion handler into a Response.
     Returns a Future with a Response.
    */
    func response() -> Future<Response, NetworkingError>

    /**
     The method used to cancel the URLSessionDataTask created using the URLRequest
    */
    func cancelURLRequest()
}

public extension RequestDispatcher {
    func response() -> Future<Response, NetworkingError> {

        return Future(resolver: { (callback: @escaping HTTPRequestResult) -> Void in
            let task: URLSessionDataTask = JSONRequestDispatcher.session.dataTask(with: self.urlRequest) {
                (data: Data?, response: URLResponse?, error: Error?) -> Void in
                // swiftlint:disable:previous closure_parameter_position

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
        })
    }

    func cancelURLRequest() {
        if #available(iOS 9.0, *) {
            JSONRequestDispatcher.session.getAllTasks { (tasks: [URLSessionTask]) -> Void in
                let filteredTasks = tasks.filter { (task: URLSessionTask) -> Bool in
                    return task.currentRequest == self.urlRequest &&
                        task.currentRequest?.httpBody == self.urlRequest.httpBody
                }

                filteredTasks.forEach { (task: URLSessionTask) -> Void in
                    task.cancel()
                }
            }

        } else {
            JSONRequestDispatcher.session.getTasksWithCompletionHandler { (dataTasks: [URLSessionDataTask], uploadTasks: [URLSessionUploadTask], downloadTasks: [URLSessionDownloadTask]) -> Void in // swiftlint:disable:this line_length
                let tasks: [URLSessionTask] = [
                    dataTasks as [URLSessionTask], uploadTasks as [URLSessionTask], downloadTasks as [URLSessionTask]
                    ].flatMap { (tasks: [URLSessionTask]) -> [URLSessionTask] in
                        return tasks
                }

                let filteredTasks: [URLSessionTask] = tasks.filter { (task: URLSessionTask) -> Bool in
                    return task.currentRequest == self.urlRequest &&
                        task.currentRequest?.httpBody == self.urlRequest.httpBody
                }

                filteredTasks.forEach { (task: URLSessionTask) -> Void in
                    task.cancel()
                }
            }
        }
    }
}
