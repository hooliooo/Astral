//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 A RequestBuilder uses the information of a Request to create an instance of URLRequest
*/
public protocol RequestBuilder {
    /**
     Initializer used to create a RequestBuilder
     - parameter request: The Request instance used to build a URLRequest
     - parameter strategy: The DataStrategy used to create the body of the http request
    */
    init(request: Request, strategy: DataStrategy)

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
     The combined Headers of the Request's RequestConfiguration and its own headers defined in its headers property.

     A Request's Header will overwrite its RequestConfiguration Header if they have identfical keys.
    */
    var headers: Set<Header> { get }

    /**
     The Request associated with the RequestBuilder
    */
    var request: Request { get set }

    /**
     The DataStrategy used to create the http body of the request
    */
    var strategy: DataStrategy { get set }

    /**
     The URLRequest used when sending an http network request
    */
    var urlRequest: URLRequest { get }
}

public extension RequestBuilder {

    public var queryItems: [URLQueryItem] {
        return self.request.parameters.flatMap { (item: (key: String, value: Any)) -> URLQueryItem? in
            return URLQueryItem(name: item.key, value: String(describing: item.value))
        }
    }

    public var url: URL {
        var components: URLComponents = self.request.configuration.baseURLComponents

        let pathComponents: [String] = self.request.configuration.basePathComponents + self.request.pathComponents

        switch pathComponents.isEmpty {
            case true:
                break

            case false:
                var path: String = pathComponents.joined(separator: "/")

                switch path.first! != "/" {
                    case true:
                        path.insert("/", at: path.startIndex)

                    case false:
                        break
                }

                components.path = path
        }

        switch self.request.isGetRequest && !self.queryItems.isEmpty {
            case true:
                components.queryItems = self.queryItems

            case false:
                break
        }

        guard let url = components.url
            else { fatalError("Invalid URL \(components)") }

        return url
    }

    public var headers: Set<Header> {
        return self.request.headers.union(self.request.configuration.baseHeaders)
    }

    public var urlRequest: URLRequest {
        var request: URLRequest = URLRequest(url: self.url)
        request.httpMethod = self.request.method.stringValue
        request.httpBody = self.httpBody

        self.headers.forEach { (header: Header) -> Void in
            request.addValue(header.value.stringValue, forHTTPHeaderField: header.key.stringValue)
        }

        return request
    }

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

        let description: String = strings.reduce(into: "") { (result: inout String, string: String) -> Void in
            result = "\(result)\n\t\(string)"
        }

        return "Type: \(type(of: self)): \(description)"
    }

    var debugDescription: String {
        return self.description
    }
}
