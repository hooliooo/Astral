//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 A DataStrategy defines the steps used to create the body for an http request
*/
public protocol DataStrategy {
    /**
     The method transforms the object instance into an optional Data
     - parameter dict: The key-value pairs to be transformed as part of the HTTP body payload.
    */
    func createHTTPBody(from dict: [String: Any]) -> Data?

}