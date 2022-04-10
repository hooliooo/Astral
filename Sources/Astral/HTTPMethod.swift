//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

/**
 An enum that represents http methods
*/
public enum HTTPMethod {
    /**
     - http GET method
    */
    case get

    /**
     - http DELETE method
    */
    case delete

    /**
     - http POST method
    */
    case post

    /**
     - http PUT method
    */
    case put

    /**
     - http PATCH method
    */
    case patch

    /**
     - other http method
    */
    case method(String)

    // MARK: Initializer
    /**
     Initializer for creating an instance of HTTPMethod

     - parameter method: The stringValue of the HTTPMethod to be created
    */
    public init(_ method: String) {
        switch method {
            case "GET": self = HTTPMethod.get
            case "DELETE": self = HTTPMethod.delete
            case "POST": self = HTTPMethod.post
            case "PUT": self = HTTPMethod.put
            case "PATCH": self = HTTPMethod.patch
            default: self = HTTPMethod.method(method)
        }
    }

    /**
     String representation of the HTTPMethod
    */
    public var stringValue: String {
        switch self {
            case .get: return "GET"
            case .delete: return "DELETE"
            case .post: return "POST"
            case .put: return "PUT"
            case .patch: return "PATCH"
            case .method(let method): return method
        }
    }
}

// MARK: Hashable Protocol
extension HTTPMethod: Hashable {

    public static func == (lhs: HTTPMethod, rhs: HTTPMethod) -> Bool {
        switch (lhs, rhs) {
            case (.get, .get): return true
            case (.delete, .delete): return true
            case (.post, .post): return true
            case (.put, .put): return true
            case (.patch, .patch): return true
            case let (.method(lhsMethod), .method(rhsMethod)): return lhsMethod == rhsMethod
            default: return false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
            case .get: hasher.combine(1337)
            case .delete: hasher.combine(1338)
            case .post: hasher.combine(1339)
            case .put: hasher.combine(1340)
            case .patch: hasher.combine(1341)
            case .method(let method):  hasher.combine(1342 &+ method.hashValue)
        }
    }

}

extension HTTPMethod: CustomStringConvertible {

    public var description: String {
        return self.stringValue
    }

}

extension HTTPMethod: CustomDebugStringConvertible {

    public var debugDescription: String {
        return self.description
    }

}
