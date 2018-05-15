//
//  Parameters.swift
//  Astral
//
//  Created by Julio Miguel Alorro on 5/15/18.
//

import Foundation

public enum Parameters {

    case dict([String: Any])

    case array([[String: Any]])

    case none

    // MARK: Computed Properties
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
