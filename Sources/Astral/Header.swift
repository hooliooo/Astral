//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

/**
 Representation of an HTTP header's name and value
*/
public struct Header {

    /**
     Representation of an HTTP header field
    */
    public enum Key: Hashable {

        /**
         Accept header field.
        */
        case accept

        /**
         Authorization header field.
        */
        case authorization

        /**
        Content-Type header field.
        */
        case contentType

        /**
         Custom header field. Has an associated value representing the header field name.
        */
        case custom(String)

        /**
         String representation of the header field.
        */
        public var stringValue: String {
            switch self {
                case .accept:
                    return "Accept"

                case .authorization:
                    return "Authorization"

                case .contentType:
                    return "Content-Type"

                case .custom(let key):
                    return key
            }
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.stringValue)
        }

        public static func == (lhs: Header.Key, rhs: Header.Key) -> Bool {
            switch (lhs, rhs) {
                case (.accept, .accept): return true
                case (.authorization, .authorization): return true
                case (.contentType, .contentType): return true
                case (.custom, .custom): return lhs.stringValue == rhs.stringValue
                default: return false
            }
        }

    }

    /**
     Representation of an HTTP header field's value
    */
    public enum Value: Hashable {

        /**
         Basic Authorization value. Must only be used with an Authorization field
        */
        case basicAuthorization(String)

        /**
         Custom header field value. Has an associated value representing the header field's value.
        */
        case custom(String)

        /**
         Media type value
        */
        case mediaType(MediaType)

        /**
         String representation of the header field value.
        */
        public var stringValue: String {
            switch self {
                case .basicAuthorization(let token):
                    return "Basic \(token)"

                case .custom(let value):
                    return value

                case .mediaType(let type):
                    return type.stringValue
            }
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.stringValue)
        }

        public static func == (lhs: Header.Value, rhs: Header.Value) -> Bool {
            switch (lhs, rhs) {
                case (.basicAuthorization, .basicAuthorization): return lhs.stringValue == rhs.stringValue
                case (.custom, .custom): return lhs.stringValue == rhs.stringValue
                case (.mediaType, .mediaType): return lhs.stringValue == rhs.stringValue
                default: return false
            }
        }
    }

    // MARK: Initializer
    /**
     Representation of a single HTTP header name and value.
     - parameter key: The HTTP header field name.
     - parameter value: The HTTP header field name's value.
    */
    public init(key: Header.Key, value: Header.Value) {
        self.key = key
        self.value = value
    }

    // MARK: Stored Properties
    /**
     The header field name.
    */
    public let key: Header.Key

    /**
     The header field name's value.
    */
    public let value: Header.Value

}

extension Header: CustomStringConvertible {
    public var description: String {
        return "\(self.key.stringValue): \(self.value.stringValue)"
    }
}

extension Header: Hashable {
    public static func == (lhs: Header, rhs: Header) -> Bool {
        return lhs.key == rhs.key
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.key)
    }

}
