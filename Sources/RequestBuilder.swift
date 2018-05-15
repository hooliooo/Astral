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
     - parameter strategy: The DataStrategy used to create the body of the http request
    */
    init(strategy: DataStrategy)

    /**
     The DataStrategy used to create the http body of the request
    */
    var strategy: DataStrategy { get set }

    /**
     Creates httpBody from the Request based on the DataStrategy if the Request is NOT a GET request. Otherwise returns nil.
     - parameter request: The Request instance used to create the httpBody.
    */
    func httpBody(of request: Request) -> Data?

    /**
     The URLRequest used when sending an http network request
     - parameter request: The Request instance used to create the URLRequest.
    */
    func urlRequest(of request: Request) -> URLRequest
}

public extension RequestBuilder {

    /**
     Creates URLQueryItems from the Request's parameters if the Request is a GET request. Otherwise returns an empty array.
     - parameter request: The Request instance used to create the URLQueryItems.
    */
    private func queryItems(of request: Request) -> [URLQueryItem] {

        switch request.parameters {
            case .dict(let dict):
                var queryItems: [URLQueryItem] = []

                for (key, value) in dict {

                    if let value = value as? [String: Any],
                        let data = try? JSONSerialization.data(withJSONObject: value),
                        let stringifiedJSON = String(data: data, encoding: String.Encoding.utf8) {

                        queryItems.append(URLQueryItem(name: key, value: stringifiedJSON))

                    } else if let arrayValues = value as? [Any] {

                        for arrayValue in arrayValues {

                            queryItems.append(URLQueryItem(name: key, value: String(describing: arrayValue)))

                        }

                    } else {

                        queryItems.append(URLQueryItem(name: key, value: String(describing: value)))

                    }

                }

                return queryItems

            case .none, .array:
                return []
        }
    }

    /**
     Creates a URL instance from the Request
     - parameter request: The Request instance used to create the URL.
    */
    private func url(of request: Request) -> URL {
        var components: URLComponents = request.configuration.baseURLComponents

        let pathComponents: [String] = request.configuration.basePathComponents + request.pathComponents

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

        let queryItems: [URLQueryItem] = self.queryItems(of: request)

        switch request.isGetRequest && !queryItems.isEmpty {
            case true:
                components.queryItems = queryItems

            case false:
                break
        }

        guard let url = components.url
            else { fatalError("Invalid URL \(components)") }

        return url
    }

    /**
     Combines the Headers of the Request's RequestConfiguration and its own headers defined in its headers property.

     A Request's Header will overwrite its RequestConfiguration Header if they have identfical keys.
     - parameter request: The Request instance used to create the HTTP header fields for the URLRequest.
    */
    private func headers(for request: Request) -> Set<Header> {
        return request.headers.union(request.configuration.baseHeaders)
    }

    public func urlRequest(of request: Request) -> URLRequest {
        var urlRequest: URLRequest = URLRequest(url: self.url(of: request))
        urlRequest.httpMethod = request.method.stringValue
        urlRequest.httpBody = self.httpBody(of: request)

        self.headers(for: request).forEach { (header: Header) -> Void in
            urlRequest.addValue(header.value.stringValue, forHTTPHeaderField: header.key.stringValue)
        }

        return urlRequest
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
