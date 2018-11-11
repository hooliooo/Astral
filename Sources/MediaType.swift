//
//  MediaType.swift
//  Astral
//
//  Created by Julio Alorro on 1/27/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

/**
 Representation of a Media Type for HTTP requests.
*/
public enum MediaType: Hashable {

    /**
     Application type with a custom subtype as an associated String value.
    */
    case application(String)

    /**
     Media type of application/json.
    */
    case applicationJSON

    /**
     Media type of application/x-www-form-urlencoded.
    */
    case applicationURLEncoded

    /**
     Multipart type with a custom subtype as an associated String value.
    */
    case multipart(String)

    /**
     Media type of multipart/form-data with a boundary parameter as an associated String value.
    */
    case multipartFormData(String)

    /**
     A representation of a custom type and subtype as associated String values with top level type on the left hand side and
     sub type on the right hand side.
    */
    case custom(String, String)

    /**
     String representation of the Media type.
    */
    public var stringValue: String {
        switch self {
            case .application(let subtype):
                return "application/\(subtype)"

            case .applicationJSON:
                return "application/json"

            case .applicationURLEncoded:
                return "application/x-www-form-urlencoded"

            case .multipart(let subtype):
                return "multipart/\(subtype)"

            case .multipartFormData(let boundary):
                return "multipart/form-data; boundary=\(boundary)"

            case .custom(let type, let subtype):
                return "\(type)/\(subtype)"
        }
    }

    public var hashValue: Int {
        return self.stringValue.hashValue
    }

    public static func == (lhs: MediaType, rhs: MediaType) -> Bool {
        switch (lhs, rhs) {
            case (.application(let lhsValue), .application(let rhsValue)): return lhsValue == rhsValue
            case (.applicationJSON, .applicationJSON): return true
            case (.applicationURLEncoded, .applicationURLEncoded): return true
            case (.multipart(let lhsValue), .multipart(let rhsValue)): return lhsValue == rhsValue
            case (.multipartFormData(let lhsValue), .multipartFormData(let rhsValue)): return lhsValue == rhsValue
            case (.custom(let lhsValue), .custom(let rhsValue)): return lhsValue == rhsValue
            default: return false
        }
    }
}
