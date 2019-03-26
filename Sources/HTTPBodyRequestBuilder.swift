//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.Data

public protocol HTTPBodyRequestBuilder: RequestBuilder {

    /**
     Initializer used to create a RequestBuilder
     - parameter strategy: The DataStrategy used to create the body of the http request
    */
    init(strategy: DataStrategy)

    /**
     The DataStrategy used to create the http body of the request
    */
    var strategy: DataStrategy { get set }

    /**
     Creates httpBody from the Request based on the DataStrategy if the Request is NOT a GET request. Otherwise returns nil.
     - parameter request: The Request instance used to create the httpBody.
    */
    func httpBody(of request: Request) -> Data?

}
