//
//  NetworkingError.swift
//  Astral
//
//  Created by Julio Alorro on 5/23/17.
//
//

public enum NetworkingError: Error {
    case invalidRequest(String)
    case noInternet(String)
    case response(String)

    var localizedDescription: String {
        switch self {
            case .invalidRequest(let parameter):
                return parameter

            case .noInternet(let string):
                return string

            case .response(let string):
                return string
        }
    }

    var title: String {
        switch self {
            case .invalidRequest:
                return "Invalid Request"
            case .noInternet:
                return "No Internet Connection"
            case .response:
                return "Response Error"
        }
    }
}
