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
 A RequestBuilder uses the information of a Request to create an instance of URLRequest
*/
public protocol RequestBuilder {
    /**
     Initializer used to create a RequestBuilder
    */
    init(request: Request)

    /**
     The HTTP network request's URL built from the Request
    */
    var url: URL { get }

    /**
     Request object's parameters as URLQueryItems
    */
    var queryItems: [URLQueryItem] { get }

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
     The URLRequest used when sending an HTTP network request
    */
    var urlRequest: URLRequest { get }
}
