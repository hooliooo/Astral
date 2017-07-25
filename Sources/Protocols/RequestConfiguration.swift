//
//  Astral
//  Copyright © 2017 Julio Alorro
//  Licensed under the MIT license. See LICENSE file
//

/**
 A RequestConfiguration defines the base URL and base headers of a Request
*/
public protocol RequestConfiguration {
    /**
     Scheme of Request
    */
    var scheme: URLScheme { get }

    /**
     Host of Request
    */
    var host: String { get }

    /**
     The URL path that is common in all Requests that use an instance of this RequestConfiguration
    */
    var basePathComponents: [String] { get }

    /**
     The URLComponents that are common in all Requests that use an isntance of this RequestConfiguration. 
     
     The default implementation creates a URLComponents instance and adds the scheme and host.
     
     The basePathComponents are typically appended by different endpoints in an API therefore aren't added to the URLComponents'
     path property. Should be finalized in the RequestBuilder.
    */
    var baseURLComponents: URLComponents { get }

    /**
     The headers that are common in all Requests that use an instance of this RequestConfiguration
    */
    var baseHeaders: [String: Any] { get }

}

public extension RequestConfiguration {

    var baseURLComponents: URLComponents {
        var components: URLComponents = URLComponents()
        components.scheme = self.scheme.rawValue
        components.host = self.host

        return components
    }
}
