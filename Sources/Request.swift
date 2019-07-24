//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.URLRequest

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

    /**
     Cache policy of the response returned by this http network request
    */
    var cachePolicy: URLRequest.CachePolicy? { get }

}

public extension Request {

    var isGetRequest: Bool {
        return self.method == HTTPMethod.get
    }

    internal var _description: String {
        let paths: [String] = self.configuration.basePathComponents + self.pathComponents
        let path: String = "/" + paths.joined(separator: "/")

        let cachePolicy: String = {
            if let cachePolicy = self.cachePolicy {
                return cachePolicy.ast.stringValue
            } else {
                return Astral.shared.session.configuration.requestCachePolicy.ast.stringValue
            }
        }()

        let string: String = """
        Method: \(self.method.stringValue)

        Scheme: \(self.configuration.scheme)

        Host: \(self.configuration.host)

        Path: \(path)

        Cache Policy: \(cachePolicy)

        Headers:
            \(createHeadersString(from: self))

        Parameters: \(self.parameters)

        """

        return """
        Type: \(type(of: self))
        \(string)
        """
    }

    var description: String {
        return """

        \(self._description)

        """
    }

    var debugDescription: String {
        return self.description
    }

}

fileprivate func createHeadersString(from request: Request) -> String { // swiftlint:disable:this private_over_fileprivate
    var headerString: String = ""

    let headers: [String] = request.headers
        .sorted { (first: Header, second: Header) -> Bool in
            return first.key.stringValue < second.key.stringValue
        }
        .map { (header: Header) -> String in
            return "\(header.key.stringValue): \(header.value.stringValue)"
        }

    if let header = headers.first {
        headerString = header

    } else {
        headerString = "No Headers"
        return headerString
    }

    switch headers.count > 1 {
        case true:
            let nextIndex: Int = headers.index(after: headers.startIndex)
            let otherHeaders: ArraySlice<String> = headers[nextIndex..<headers.count]

            headerString.append("\n\t")

            headerString += otherHeaders
                .map { (otherHeader: String) -> String in
                    switch otherHeader == otherHeaders.last {
                        case true:
                            return otherHeader

                        case false:
                            return otherHeader + "\n\t"
                    }
                }
                .joined()

        case false:
            break
    }

    return headerString
}
