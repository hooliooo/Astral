//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
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
    case other(String)

    // MARK: Initializer
    /**
     Initializer for creating an instance of HTTPMethod

     - parameter method: The stringValue of the HTTPMethod to be created
    */
    public init(_ method: String ) {
        switch method {
            case "GET": self = HTTPMethod.get
            case "DELETE": self = HTTPMethod.delete
            case "POST": self = HTTPMethod.post
            case "PUT": self = HTTPMethod.put
            case "PATCH": self = HTTPMethod.patch
            default: self = HTTPMethod.other(method)
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
            case .other(let method): return method
        }
    }
}

extension HTTPMethod: Equatable {

    public static func == (lhs: HTTPMethod, rhs: HTTPMethod) -> Bool {
        switch (lhs, rhs) {
            case (.get, .get): return true
            case (.delete, .delete): return true
            case (.post, .post): return true
            case (.put, .put): return true
            case (.patch, .patch): return true
            case (.other(let lhsMethod), .other(let rhsMethod)): return lhsMethod == rhsMethod
            default: return false
        }
    }

}

extension HTTPMethod: Hashable {

    public var hashValue: Int {
        switch self {
            case .get: return 1337
            case .delete: return 1338
            case .post: return 1339
            case .put: return 1340
            case .patch: return 1341
            case .other(let method):  return 1342 &+ method.hashValue
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
