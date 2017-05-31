//
//  Configuration.swift
//  Astral
//
//  Created by Julio Alorro on 5/21/17.
//
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
     The root URL path of the HTTP network request
    */
    var basePathComponents: [String] { get }

    /**
     The root URL of the HTTP network request
    */
    var baseURL: URL { get }

    /**
     The base headers of the HTTP network request
    */
    var baseHeaders: [String: Any] { get }

}

public extension Configuration {

    var baseURL: URL {
        var components: URLComponents = URLComponents()
        components.scheme = self.scheme.rawValue
        components.host = self.host

        switch basePathComponents.isEmpty {
            case true:
                break

            case false:
                var path: String = self.basePathComponents.joined(separator: "/")

                switch path.characters.first! != "/" {
                    case true:
                        path.insert("/", at: path.startIndex)
                    
                    case false:
                        break
                }

                components.path = path
        }

        return components.url!
    }
}
