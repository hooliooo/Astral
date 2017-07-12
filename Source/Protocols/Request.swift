//
//  Astral
//  Copyright © 2017 Julio Alorro
//  Licensed under the MIT license. See LICENSE file
//

/**
 A Request contains the information required to make an HTTP network request
*/
public protocol Request {
    /**
     The Configuration used by the Request
    */
    var configuration: Configuration { get }

    /**
     HTTP method of the HTTP request
    */
    var method: HTTPMethod { get }

    /**
     Determines whether the HTTP method is a GET or not
    */
    var isGetRequest: Bool { get }

    /**
     URL path to API Endpoint
    */
    var pathComponents: [String] { get }

    /**
     HTTP parameters to be sent in the HTTP network request body or as query string(s) in the URL
    */
    var parameters: [String: Any] { get }

    /**
     HTTP headers to be sent with the HTTP network request
    */
    var headers: [String: Any] { get }
}

public extension Request {

    var isGetRequest: Bool {
        return self.method == HTTPMethod.GET
    }

}
