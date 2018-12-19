//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.URLRequest
import class Foundation.FileManager
import struct Foundation.URL

/**
 An implementation of RequestBuilder that creates a URLRequest for multipart form data uploads.
 */
public class MultiPartFormDataBuilder: RequestBuilder {

    // MARK: Initializer
    /**
     An implementation of RequestBuilder that creates a URLRequest for multipart form data uploads.
    */
    public init() {}

    // MARK: Stored Properties
    /**
     The MultiPartFormDataStrategy instance
    */
    public let strategy: MultiPartFormDataStrategy = MultiPartFormDataStrategy()

    // MARK: Computed Properties
    /**
     The underlying FileManager of the MultiPartFormDataBuilder instance
    */
    public var fileManager: FileManager {
        return self.strategy.fileManager
    }

    /**
     Creates a URLRequest based on the information of the Request. If the request is not a MultiPartFormDataRequest,
     returns a URLRequest without an httpBody. Otherwise creates a URLRequest with the form data transformed as Data in the
     URLRequest's httpBody property.
     - parameter request: The Request instance. This Request should be a MultiPartFormDataRequest type.
    */
    public func urlRequest(of request: Request) -> URLRequest {
        guard let multipartFormDataRequest = request as? MultiPartFormDataRequest else {
            return self._urlRequest(of: request)
        }

        var urlRequest = self._urlRequest(of: multipartFormDataRequest)
        urlRequest.httpBody = self.strategy.createHTTPBody(from: multipartFormDataRequest)
        return urlRequest
    }

    /**
     Creates a URLReqeust with the form data transformed into an InputStream in URLRequest's httpBodyStream property. Throws an error.
     - parameter request: The MultiPartFormDataRequest instance.
    */
    public func multipartFormDataURLRequest(of request: MultiPartFormDataRequest) throws -> URLRequest {
        var urlRequest: URLRequest = self._urlRequest(of: request)
        let fileURL: URL = self.strategy.fileURL(for: request)
        //        let attributeDict: [FileAttributeKey: Any] = try self.fileManager.attributesOfItem(atPath: fileURL.path)
        //
        //        guard let fileSize = attributeDict[FileAttributeKey.size] as? NSNumber else {
        //            throw MultiPartFormDataBuilder.ReadError.couldNotReadFileSize
        //        }
        //
        //        urlRequest.addValue("\(fileSize.uint64Value)", forHTTPHeaderField: "Content-Length")
        urlRequest.httpBodyStream = try self.strategy.createHTTPStreamBody(from: request, at: fileURL)
        return urlRequest
    }

}
