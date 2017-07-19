//
//  Astral
//  Copyright © 2017 Julio Alorro
//  Licensed under the MIT license. See LICENSE file
//

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
     The root URL path components of the http network request
    */
    var basePathComponents: [String] { get }

    /**
     The root URLComponents of the http network request
    */
    var baseURLComponents: URLComponents { get }

    /**
     The base headers of the http network request
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
