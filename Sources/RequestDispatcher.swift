//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.URLSession
import class Foundation.URLSessionTask
import struct Foundation.URLRequest

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
     The Request Builder associated with the RequestDispatcher
    */
    var builder: RequestBuilder { get set }

    /**
     When set to true, the headers of the HTTPURLResponse is printed in the console log. Use for debugging purposes
    */
    var isDebugMode: Bool { get }

    /**
     The URLRequest associated with the RequestDispatcher.
     - parameter request: The Request instance used to build the URLRequest from the RequestBuilder.
    */
    func urlRequest(of request: Request) -> URLRequest

}
