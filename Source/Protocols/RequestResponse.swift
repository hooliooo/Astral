//
//  RequestResponse.swift
//  Pods
//
//  Created by Julio Alorro on 6/20/17.
//
//

import Foundation

public protocol RequestResponse {

    /**
     Initializer for RequestResponse
    */
    init(httpResponse: HTTPURLResponse, data: Data)

    /**
     Status code of the HTTP Response
    */
    var statusCode: Int { get }

    /**
     Payload of information from the HTTP Response
    */
    var payload: JSON { get }

}
