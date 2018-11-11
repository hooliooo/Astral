//
//  Parameters.swift
//  Astral
//
//  Created by Julio Miguel Alorro on 5/15/18.
//

/**
 Representation of an HTTP request's body (when the method is POST, PUT, DELETE) or query (when the method is GET).
*/
public enum Parameters {

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
}
