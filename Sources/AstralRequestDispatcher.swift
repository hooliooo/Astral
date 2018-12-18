//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.URLSessionTask
import class Foundation.URLSession
import struct Foundation.URLRequest
import class Foundation.NSObject

/**
 An implementation of RequestDispatcher that uses the URLSession shared instance for http network requests.
*/
open class AstralRequestDispatcher: NSObject {

    // MARK: Intializers
    /**
     AstralRequestDispatcher is an abstract class that provides the base implementation of the RequestDispatcher protocol.
     - parameter builder: The RequestBuilder used to create the URLRequest instance.
     - parameter isDebugMode: If true, the console will print out information related to the http networking request. If false, prints nothing.
    */
    public init(
        builder: RequestBuilder,
        isDebugMode: Bool = true
    ) {
        guard type(of: self) != AstralRequestDispatcher.self else {
            fatalError(
                "AstralRequestDispatcher instances cannot be created. Use subclasses instead"
            )
        }

        self._requestBuilder = builder
        self._isDebugMode = isDebugMode
        super.init()
    }

    deinit {
        switch self._isDebugMode {
            case true:
                print("\(type(of: self)) was deallocated")

            case false:
                break
        }
    }

    // MARK: Stored Properties
    private var _requestBuilder: RequestBuilder
    private let _isDebugMode: Bool
    private var _taskCache: [URLSessionTask: Request] = [:]

    // MARK: Computed Properties
    open var session: URLSession {
        return Astral.shared.session
    }

}

extension AstralRequestDispatcher: RequestDispatcher {

    // MARK: Getter/Setter Properties
    open var builder: RequestBuilder {
        get { return self._requestBuilder }

        set { self._requestBuilder = newValue }
    }

    open var isDebugMode: Bool {
        return self._isDebugMode
    }

    open var taskCache: [URLSessionTask: Request] {
        get { return self._taskCache }

        set { self._taskCache = newValue }
    }

    open func urlRequest(of request: Request) -> URLRequest {
        return self._requestBuilder.urlRequest(of: request)
    }

    open func cancel() {
        for task in self._taskCache.keys {
            task.cancel()
        }

        self.removeTasks()
    }

    public final func add(task: URLSessionTask, with request: Request) {
        self._taskCache.updateValue(request, forKey: task)
    }

    @discardableResult
    public final func remove(task: URLSessionTask) -> (URLSessionTask, Request)? {
        if let request = self._taskCache.removeValue(forKey: task) {
            return (task, request)
        } else {
            return nil
        }
    }

    public final func removeTasks() {
        self._taskCache.removeAll()
    }
}
