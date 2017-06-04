//
//  JSONRequestBuilder.swift
//  Astral
//
//  Created by Julio Alorro on 5/31/17.
//
//

public struct JSONRequestBuilder {

    // MARK: Stored Properties
    fileprivate let _request: Request

    // MARK: Computed Properties
    fileprivate var url: URL {
        var components: URLComponents = self.request.configuration.baseURLComponents

        let pathComponents: [String] = self.request.configuration.basePathComponents + self.request.pathComponents

        switch pathComponents.isEmpty {
            case true:
                break

            case false:
                var path: String = pathComponents.joined(separator: "/")

                switch path.characters.first! != "/" {
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

    /**
     Request object's parameters as URLQueryItems
     */
    fileprivate var queryItems: [URLQueryItem] {
        return self.request.parameters.flatMap { (item: (key: String, value: Any)) -> URLQueryItem? in
            guard let value = item.value as? String
                else { return nil }

            return URLQueryItem(name: item.key, value: value)

        }
    }

    /**
     Request object's parameters as Data
     */
    fileprivate var httpBody: Data? {
        if self.request.parameters.isEmpty || self.request.isGetRequest {
            return nil
        }

        return try? JSONSerialization.data(withJSONObject: self.request.parameters)
    }

    /**
     Combined headers of Request object's configuration and its headers
     */
    fileprivate var headers: [String: Any] {
        return [self.request.configuration.baseHeaders, self.request.headers].reduce([:]) {
            (result: [String: Any], dict: [String : Any]) -> [String: Any] in
            var result: [String: Any] = result
            dict.forEach { (dict: (key: String, value: Any)) -> Void in
                result.updateValue(dict.value, forKey: dict.key)
            }
            return result
        }
    }
}

// MARK: - RequestBuilder Protocol
extension JSONRequestBuilder: RequestBuilder {
    // MARK: Initializer
    public init(request: Request) {
        self._request = request
    }

    // MARK: Computed Properties
    public var request: Request {
        return self._request
    }

    public var urlRequest: URLRequest {
        var request: URLRequest = URLRequest(url: self.url)
        request.httpMethod = self.request.method.rawValue
        request.httpBody = self.httpBody

        self.headers.forEach {
            if let value = $1 as? String {
                request.addValue(value, forHTTPHeaderField: $0)
            } else {
                print("No headers")
            }
        }
        
        return request
    }
}
