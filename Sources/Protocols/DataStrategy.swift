//
//  Astral
//  Copyright (c) 2017 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

public protocol DataStrategy {

    /**
     The method transforms the object instance into an optional Data
     - parameter object: The object to be transformed in to Data
    */
    func createHTTPBody(from dict: [String: Any]) -> Data?

}
