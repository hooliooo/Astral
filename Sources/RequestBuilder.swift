//
//  Astral
//  Copyright (c) 2017-2019 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.Data
import struct Foundation.URL
import struct Foundation.URLRequest
import struct Foundation.URLQueryItem
import struct Foundation.URLComponents
import class Foundation.JSONSerialization

/**
 A RequestBuilder uses the information of a Request to create an instance of URLRequest
*/
public protocol RequestBuilder {

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
    public func queryItems(of request: Request) -> [URLQueryItem] {

        switch request.parameters {
            case .dict(let dict):
                var queryItems: [URLQueryItem] = []

                for (key, value) in dict {

                    if let value = value as? [String: Any],
                        let data = try? JSONSerialization.data(withJSONObject: value),
                        let stringifiedJSON: String = String(data: data, encoding: String.Encoding.utf8) {

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
    public func url(of request: Request) -> URL {
        var components: URLComponents = request.configuration.baseURLComponents

        let pathComponents: [String] = request.configuration.basePathComponents + request.pathComponents

        switch pathComponents.isEmpty {
            case true:
                break

            case false:
                var path: String = pathComponents.joined(separator: "/")

                if let firstPath = path.first, firstPath != "/" {
                    path.insert("/", at: path.startIndex)
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
    public func headers(for request: Request) -> Set<Header> {
        return request.headers.union(request.configuration.baseHeaders)
    }

    /**
     Creates the URLRequest from a request. Adds the httpMethod and headers.
     - parameter request: Request instance used to create the URLRequest.
    */
    internal func _urlRequest(of request: Request) -> URLRequest {
        var urlRequest: URLRequest = URLRequest(url: self.url(of: request))
        urlRequest.httpMethod = request.method.stringValue
        self.headers(for: request).forEach { (header: Header) -> Void in
            urlRequest.addValue(header.value.stringValue, forHTTPHeaderField: header.key.stringValue)
        }

        return urlRequest

    }

}
