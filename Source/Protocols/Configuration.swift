//  The MIT License (MIT)

//  Copyright (c) 2017 Julio Alorro

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
 A Configuration defines the base URL and base headers of the Request that uses an instance of this Configuration.
*/
public protocol Configuration {
    /**
     Scheme of network request
    */
    var scheme: URLScheme { get }

    /**
     Host of network request
    */
    var host: String { get }

    /**
     The root URL path components of the HTTP network request
    */
    var basePathComponents: [String] { get }

    /**
     The root URLComponents of the HTTP network request
    */
    var baseURLComponents: URLComponents { get }

    /**
     The base headers of the HTTP network request
    */
    var baseHeaders: [String: Any] { get }

}

public extension Configuration {

    var baseURLComponents: URLComponents {
        var components: URLComponents = URLComponents()
        components.scheme = self.scheme.rawValue
        components.host = self.host

        return components
    }
}
