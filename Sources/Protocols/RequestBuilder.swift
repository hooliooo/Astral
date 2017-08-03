//
//  Astral
//  Copyright (c) 2017 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

/**
 A RequestBuilder uses the information of a Request to create an instance of URLRequest
*/
public protocol RequestBuilder: CustomStringConvertible, CustomDebugStringConvertible {
    /**
     Initializer used to create a RequestBuilder
    */
    init(request: Request)

    /**
     Request object's parameters as URLQueryItems
    */
    var queryItems: [URLQueryItem] { get }

    /**
     The http network request's URL built from the Request
    */
    var url: URL { get }

    /**
     Request object's parameters as Data
    */
    var httpBody: Data? { get }

    /**
     Combined headers of Request's Configuration and its headers
    */
    var headers: [String: Any] { get }

    /**
     The Request associated with the RequestBuilder
    */
    var request: Request { get }

    /**
     The URLRequest used when sending an http network request
    */
    var urlRequest: URLRequest { get }
}

public extension RequestBuilder {
    var description: String {
        let strings: [String] = [
            "QueryItems: \(self.queryItems)",
            "URL: \(self.url)",
            "Http Body: \(String(describing: self.httpBody))",
            "Headers: \(self.headers)",
            "URLRequest: \(self.urlRequest)"
        ]

        let descriptionString: String = strings.reduce("") { (result: String, string: String) -> String in
            return "\(result)\n\t\(string)"
        }
        return "Type: \(type(of: self)): \(descriptionString)"
    }

    var debugDescription: String {
        return self.description
    }
}
