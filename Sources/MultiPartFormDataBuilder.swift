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
import func CoreFoundation.CFAbsoluteTimeGetCurrent

/**
 An implementation of RequestBuilder that creates a URLRequest for multipart form data uploads.
 */
public class MultiPartFormDataBuilder: RequestBuilder {

    public enum Error: Swift.Error {
        case notData
        case notURL

        public var localizedDescription: String {
            switch self {
                case .notData:
                    return "Expecting Data but got URL instead"
                c
                        ase .notURL:
                    return "Expecting URL but got Data instead"
            }
        }
    }

    public func urlRequest(of request: Request) -> URLRequest {
        return self._urlRequest(of: request)
    }

    /**
     Creates the body of the multipart form data request. Loads the entire multipart form data into memory. This should
     only be used with requests that have a small memory footprint.
     - parameter request: The MultiPartFormDataRequest instance
    */
    public func data(of request: MultiPartFormDataRequest) throws -> Data {
        let strategy: MultiPartFormDataStrategy = MultiPartFormDataStrategy()
        let prefixData: Data = strategy.createHTTPBody(from: request.parameters)!
        let postfixData: Data = strategy.postfixData

        let start = CFAbsoluteTimeGetCurrent()

        var encodedData: Data = Data()
        encodedData.append(prefixData)

        for component in request.components {

            switch component.file {
                case .data(let data):
                    let boundaryPrefix: String = "--\(Astral.shared.boundary)\r\n"
                    strategy.append(string: boundaryPrefix, to: &encodedData)
                    strategy.append(
                        string: "Content-Disposition: form-data; name=\"\(component.name)\"; filename=\"\(component.fileName)\"\r\n",
                        to: &encodedData
                    )

                    strategy.append(string: "Content-Type: \(component.contentType)\r\n\r\n", to: &encodedData)
                    encodedData.append(data)
                    strategy.append(string: "\r\n", to: &encodedData)

                case .url(let url):
                    throw MultiPartFormDataBuilder.Error.notData
            }

        }

        encodedData.append(postfixData)

        let end = CFAbsoluteTimeGetCurrent()

        print((end - start) as Double)

        return encodedData
    }

}
