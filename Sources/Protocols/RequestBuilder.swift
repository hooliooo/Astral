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
     Combined headers of Request's Configuration and its headers
    */
    var headers: [String: Any] { get }

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

    public var headers: [String: Any] {
        let headersArray: [[String: Any]] = [self.request.configuration.baseHeaders, self.request.headers]

        return headersArray.reduce(into: [:]) { (result: inout [String: Any], dict: [String: Any]) -> Void in
            dict.forEach { (dict: (key: String, value: Any)) -> Void in
                result.updateValue(dict.value, forKey: dict.key)
            }
        }
    }

    public var urlRequest: URLRequest {
        var request: URLRequest = URLRequest(url: self.url)
        request.httpMethod = self.request.method.stringValue
        request.httpBody = self.httpBody

        self.headers.forEach { (key: String, value: Any) -> Void in
            if let value = value as? String {
                request.addValue(value, forHTTPHeaderField: key)
            }
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
