//
//  Astral
//  Copyright © 2017 Julio Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 A Response encapsulates the data retreived after an http request was made.
*/
public protocol Response {

    /**
     Initializer for RequestResponse
    */
    init(httpResponse: HTTPURLResponse, data: Data)

    /**
     Status code of the http Response
    */
    var statusCode: Int { get }

    /**
     Payload of information from the http Response as Data
    */
    var data: Data { get }

    /**
     Payload of information from the http Response as JSON
    */
    var payload: JSON { get }

}
