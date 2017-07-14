//
//  Astral
//  Copyright © 2017 Julio Alorro
//  Licensed under the MIT license. See LICENSE file
//

import BrightFutures

/**
 A RequestSender uses the URLRequest of the RequestBuilder to make an
 http network request using the system's URLSession shared instance.
*/
public protocol RequestSender {
    /**
     Initializer using a Request
    */
    init(request: Request, printsResponse: Bool)

    /**
     Initializer using a RequestBuiler
    */
    init(builder: RequestBuilder, printsResponse: Bool)

    /**
     The Request associated with the RequestSender
    */
    var request: Request { get }

    /**
     The URLRequest associated with the RequestSender
    */
    var urlRequest: URLRequest { get }

    /**
     When set to true, the headers of the httpURLResponse is printed in the console log. Use for debugging purposes
    */
    var printsResponse: Bool { get }

    /**
     The method used to make an http network request by creating a URLSessionDataTask from the URLRequest instance. 
     Returns a Future.
    */
    func sendURLRequest() -> Future<Response, NetworkingError>

    /**
     The method used to cancel the URLSessionDataTask created using the URLRequest
    */
    func cancelURLRequest()
}
