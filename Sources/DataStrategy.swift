//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.Data

/**
 A DataStrategy defines the steps used to create the body for an http request
*/
public protocol DataStrategy {
    /**
     The method transforms the object instance into an optional Data
     - parameter request: The Request instance used to create the httpBody of a URLRequest.
    */
    func createHTTPBody(from request: Request) -> Data?

}
