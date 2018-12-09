//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.NSObject
import struct Foundation.Data
import struct Foundation.URLRequest
import class Foundation.InputStream
import class Foundation.FileManager
import struct Foundation.URL

/**
 An implementation of RequestBuilder that creates a URLRequest for multipart form data uploads.
 */
public class MultiPartFormDataBuilder: RequestBuilder {

    public func urlRequest(of request: Request) -> URLRequest {
        return self._urlRequest(of: request)
    }

    /**
     Creates the body of the multipart form data request.
     - parameter request: The MultiPartFormDataRequest instance
    */
    public func data(of request: MultiPartFormDataRequest) -> Data {
        let strategy: MultiPartFormDataStrategy = MultiPartFormDataStrategy()
        let prefixData: Data = strategy.createHTTPBody(from: request.parameters)!
        let postfixData: Data = strategy.postfixData

        var data: Data = Data()
        data.append(prefixData)
        request.files.forEach { data.append($0.bodyData) }
        data.append(postfixData)

        return data
    }

}
