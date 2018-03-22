//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 A RequestDispatcher uses the URLRequest of the RequestBuilder to make an
 http network request using the a URLSession instance.
*/
public protocol RequestDispatcher: class {
    /**
     The URLSession used for the RequestDispatcher type
    */
    var session: URLSession { get }

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
    var tasks: [URLSessionTask] { get set }

    /**
     The URLRequest associated with the RequestDispatcher.
     - parameter request: The Request instance used to build the URLRequest from the RequestBuilder.
    */
    func urlRequest(of request: Request) -> URLRequest

    /**
     Cancels all URLSessionTasks created by this RequestDispatcher
    */
    func cancel()

    /**
     Adds a task to the tasks array
     - parameter task: URLSessionTask to add.
    */
    func add(task: URLSessionTask)

    /**
     Removes a task to the tasks array
     - parameter task: URLSessionTask to remove.
    */
    @discardableResult
    func remove(task: URLSessionTask) -> URLSessionTask?

    /**
     Removes all tasks from the tasks array.
    */
    @discardableResult
    func removeTasks() -> [URLSessionTask]
}
