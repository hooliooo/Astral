//
//  Astral
//  Copyright © 2017 Julio Alorro
//  Licensed under the MIT license. See LICENSE file
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
     Payload of information from the HTTP Response as Data
    */
    var data: Data { get }

    /**
     Payload of information from the HTTP Response as JSON
    */
    var payload: JSON { get }

}
