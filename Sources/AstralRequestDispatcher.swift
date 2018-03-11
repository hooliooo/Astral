//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 An implementation of RequestDispatcher that uses the URLSession shared instance for http network requests.
*/
open class AstralRequestDispatcher {

    // MARK: Intializers
    public required init(builder: RequestBuilder = BaseRequestBuilder(strategy: JSONStrategy()), isDebugMode: Bool = true) {
        self._requestBuilder = builder
        self._isDebugMode = isDebugMode
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
    private var _tasks: [URLSessionTask] = []

    // MARK: Static Properties
    open class var session: URLSession {
        return URLSession.shared
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

    open var tasks: [URLSessionTask] {
        get { return self._tasks }

        set { self._tasks = newValue }
    }

    open func urlRequest(of request: Request) -> URLRequest {
        return self._requestBuilder.urlRequest(of: request)
    }

    open func cancel() {
        for task in self._tasks {
            task.cancel()
        }

        self.removeTasks()
    }

    public final func add(task: URLSessionTask) {
        self._tasks.append(task)
    }

    @discardableResult
    public final func remove(task: URLSessionTask) -> URLSessionTask? {
        if let idx = self._tasks.index(of: task) {
            return self._tasks.remove(at: idx)
        } else {
            return nil
        }
    }

    @discardableResult
    public final func removeTasks() -> [URLSessionTask] {
        let tasks: [URLSessionTask] = self._tasks
        self._tasks.removeAll()
        return tasks
    }
}
