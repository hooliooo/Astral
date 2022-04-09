//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

/**
 Representation of an HTTP request's body (when the method is POST, PUT, DELETE) or query (when the method is GET).
*/
public enum Parameters: CustomStringConvertible, CustomDebugStringConvertible {

    /**
     A single [String: Any] dictionary.
    */
    case dict([String: Any])

    /**
     An array of [String: Any] dictionaries.
    */
    case array([[String: Any]])

    /**
     No parameters.
    */
    case none

    // MARK: Computed Properties
    /**
     Boolean that checks if Parameters exist.
    */
    public var isEmpty: Bool {
        switch self {
            case .dict(let dict):
                return dict.isEmpty

            case .array(let array):
                return array.isEmpty

            case .none:
                return true
        }
    }

    /**
     The dictionary value of the Parameters instance if it is a .dict. Otherwise, returns nil.
    */
    public var dictValue: [String: Any]? { // swiftlint:disable:this discouraged_optional_collection
        guard case .dict(let dict) = self else { return nil }
        return dict
    }

    /**
     The array value of the Parameters instance if it is a .array. Otherwise, returns nil.
    */
    public var arrayValue: [[String: Any]]? { // swiftlint:disable:this discouraged_optional_collection
        guard case .array(let array) = self else { return nil }
        return array
    }

    public var description: String {
        switch self {
            case .dict(let dict):
                return dict.description
            case .array(let array):
                return array.description
            case .none:
                return "No parameters"
        }
    }

    public var debugDescription: String {
        return self.description
    }
}
