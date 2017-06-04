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
