//
//  Astral
//  Copyright (c) 2017 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 A Response encapsulates the data retreived after an http request was made.
*/
public protocol Response {
    /**
     Initializer for Response
    */
    init(httpResponse: HTTPURLResponse, data: Data)

    /**
     Status code of the http response
    */
    var statusCode: Int { get }

    /**
     Payload of information from the http response as Data
    */
    var data: Data { get }

    /**
     Payload of information from the http response as JSON
    */
    var json: JSON { get }

}
