//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

/**
 A Request contains the information required to make an http network request. A Request represents one network operation.
*/
public protocol Request: CustomStringConvertible, CustomDebugStringConvertible {
    /**
     The RequestConfiguration used by the Request
    */
    var configuration: RequestConfiguration { get }

    /**
     http method of the http request
    */
    var method: HTTPMethod { get }

    /**
     URL path to API Endpoint
    */
    var pathComponents: [String] { get }

    /**
     http parameters to be sent in the http network request body or as query string(s) in the URL
    */
    var parameters: Parameters { get }

    /**
     http headers to be sent with the http network request
    */
    var headers: Set<Header> { get }

}

public extension Request {

    var isGetRequest: Bool {
        return self.method == HTTPMethod.get
    }

    var description: String {
        let strings: [String] = [
            "Method: \(self.method)",
            "PathComponents: \(self.pathComponents)",
            "Parameters: \(self.parameters)",
            "Headers: \(self.headers)"
        ]

        let description: String = strings.reduce(into: "") { (result: inout String, string: String) -> Void in
            result = "\(result)\n\t\(string)"
        }

        return "Type: \(type(of: self)): \(description)"
    }

    var debugDescription: String {
        return self.description
    }

}
