//  The MIT License (MIT)

//  Copyright © 2017 Julio Alorro

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

/**
 An implementation of RequestBuilder that can build URLRequests for simple HTTP network requests.
*/
public struct JSONRequestBuilder {

    // MARK: Stored Properties
    fileprivate let _request: Request

}

// MARK: - RequestBuilder Protocol
extension JSONRequestBuilder: RequestBuilder {

    // MARK: Initializer
    public init(request: Request) {
        self._request = request
    }

    // MARK: Computed Properties
    public var url: URL {
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

    public var queryItems: [URLQueryItem] {
        return self.request.parameters.flatMap { (item: (key: String, value: Any)) -> URLQueryItem? in
            guard let value = item.value as? String
                else { return nil }

            return URLQueryItem(name: item.key, value: value)

        }
    }

    public var httpBody: Data? {
        if self.request.parameters.isEmpty || self.request.isGetRequest {
            return nil
        }

        return try? JSONSerialization.data(withJSONObject: self.request.parameters)
    }

    public var headers: [String: Any] {
        return [self.request.configuration.baseHeaders, self.request.headers].reduce([:]) {
            (result: [String: Any], dict: [String : Any]) -> [String: Any] in
            var result: [String: Any] = result
            dict.forEach { (dict: (key: String, value: Any)) -> Void in
                result.updateValue(dict.value, forKey: dict.key)
            }
            return result
        }
    }

    public var request: Request {
        return self._request
    }

    public var urlRequest: URLRequest {
        var request: URLRequest = URLRequest(url: self.url)
        request.httpMethod = self.request.method.rawValue
        request.httpBody = self.httpBody

        self.headers.forEach { (key: String, value: Any) -> Void in
            if let value = value as? String {
                request.addValue(value, forHTTPHeaderField: key)
            } else {
                print("No headers")
            }
        }
        
        return request
    }
}
