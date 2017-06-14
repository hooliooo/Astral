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

import BrightFutures

/**
 A RequestSender uses the URLRequest of the RequestBuilder to make an
 HTTP network request using the system's URLSession shared instance.
*/
public protocol RequestSender {
    /**
     Initializer using a Request
    */
    init(request: Request, printsResponse: Bool)

    /**
     Initializer using a RequestBuiler
    */
    init(builder: RequestBuilder, printsResponse: Bool)

    /**
     The Request associated with the RequestSender
    */
    var request: Request { get }

    /**
     The URLRequest associated with the RequestSender
    */
    var urlRequest: URLRequest { get }

    /**
     When set to true, the headers of the HTTPURLResponse is printed in the console log. Use for debugging purposes
    */
    var printsResponse: Bool { get }

    /**
     The method used to make an HTTP network request by creating a URLSessionDataTask from the URLRequest instance. 
     Returns a Future.
    */
    func sendURLRequest() -> Future<Data, NetworkingError>

    /**
     The method used to cancel the URLSessionDataTask created using the URLRequest
    */
    func cancelURLRequest()
}
