//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation
import BrightFutures
import Result

/**
 A RequestDispatcher uses the URLRequest of the RequestBuilder to make an
 http network request using the a URLSession instance.
*/
public protocol RequestDispatcher: class {
    /**
     The URLSession used for the RequestDispatcher type
    */
    static var session: URLSession { get }

    /**
     Initializer with a Request and RequestBuilder type
     - parameter request: The Request instance used to build a URLRequest in the RequestBuilder
     - parameter builderType: The type of RequestBuilder that will be initialized to create the URLRequest
     - parameter strategy: The DataStrategy used to create the body of the http request
     - parameter isDebugMode: Indicates whether the HTTPURLResponse will be printed to the console or not
    */
    init(builderType: RequestBuilder.Type, strategy: DataStrategy, isDebugMode: Bool)

    /**
     Initializer using a RequestBuiler
     - parameter builder: The RequestBuilder instance used to build a URLRequest
     - parameter isDebugMode: Indicates whether the HTTPURLResponse will be printed to the console or not
    */
    init(builder: RequestBuilder, isDebugMode: Bool)

    /**
     The Request Builder associated with the RequestDispatcher
    */
    var builder: RequestBuilder { get set }

    /**
     When set to true, the headers of the HTTPURLResponse is printed in the console log. Use for debugging purposes
    */
    var isDebugMode: Bool { get }

    /**
     The URLSessionTasks created by this instance
    */
    var tasks: [URLSessionTask] { get }

    /**
     The URLRequest associated with the RequestDispatcher.
     - parameter request: The Request instance used to build the URLRequest from the RequestBuilder.
    */
    func urlRequest(of request: Request) -> URLRequest

    /**
     Creates a URLSessionDataTask from the URLRequest and transforms the Data or Error from the completion handler
     into a Response or NetworkingError. Returns a Future with a Response or NetworkingError.
     - parameter request: The Request instance used to get the Future<Response, NetworkingError> instance.
    */
    func response(of request: Request) -> Future<Response, NetworkingError>

    /**
     Cancels all URLSessionTasks created by this RequestDispatcher
    */
    func cancel()
}
