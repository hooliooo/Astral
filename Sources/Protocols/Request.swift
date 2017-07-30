//
//  Astral
//  Copyright (c) 2017 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

/**
 A Request contains the information required to make an http network request. A Request represents one network operation.
*/
public protocol Request {
    /**
     The RequestConfiguration used by the Request
    */
    var configuration: RequestConfiguration { get }

    /**
     http method of the http request
    */
    var method: HTTPMethod { get }

    /**
     Determines whether the http method is a GET or not
    */
    var isGetRequest: Bool { get }

    /**
     URL path to API Endpoint
    */
    var pathComponents: [String] { get }

    /**
     http parameters to be sent in the http network request body or as query string(s) in the URL
    */
    var parameters: [String: Any] { get }

    /**
     http headers to be sent with the http network request
    */
    var headers: [String: Any] { get }
}

public extension Request {

    var isGetRequest: Bool {
        return self.method == HTTPMethod.GET
    }

}
