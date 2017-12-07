//
//  Astral
//  Copyright (c) 2017 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 An implementation of DataStrategy specifically for creating an HTTP body for multipart form-data.
*/
public struct MultiPartFormDataStrategy {

    // MARK: Initializer
    /**
     Initializer.
     - parameter request: The MultiPartFormDataRequest instance used to create the MultiPartFormDataStrategy instance.
    */
    public init(request: MultiPartFormDataRequest) {
        self.boundary = request.boundary
        self.data = request.data
        self.filename = request.fileName
        self.mimeType = request.mimeType
    }

    // MARK: Stored Properties
    /**
     The defined boundary to be used in creating the multipart form-data HTTP body.
    */
    public let boundary: String

    /**
     The data to be uploaded as part of the multipart form-data payload.
    */
    public let data: Data

    /**
     The file name to be used as part of the multipart form-data payload.
    */
    public let filename: String

    /**
     The mime type to be defined as the Content-Type in the multipart form-data payload.
    */
    public let mimeType: String

    // MARK: Instance Methods
    /**
     The method used to modify the HTTP body to create the multipart form-data payload.
     - parameter string: The string to be converted into Data.
     - parameter data: The data the string will be appended to.
    */
    private func append(string: String, to data: inout Data) {
        let stringData: Data = string.data(using: String.Encoding.utf8)!
        data.append(stringData)
    }

}

// MARK: - DataStrategy Methods
extension MultiPartFormDataStrategy: DataStrategy {

    public func createHTTPBody(from dict: [String: Any]) -> Data? {
        var body: Data = Data()
        let boundaryPrefix: String = "--\(self.boundary)\r\n"

        switch dict.isEmpty {
            case true:
                break

            case false:
                for (key, value) in dict {
                    self.append(string: boundaryPrefix, to: &body)
                    self.append(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n", to: &body)

                    let value: String = String(describing: value)
                    self.append(string: "\(value)\r\n", to: &body)
                }
        }

        self.append(string: boundaryPrefix, to: &body)
        self.append(string: "Content-Disposition: form-data; name=\"file\"; filename=\"\(self.filename)\"\r\n", to: &body)
        self.append(string: "Content-Type: \(self.mimeType)\r\n\r\n", to: &body)

        body.append(self.data)

        self.append(string: "\r\n", to: &body)
        self.append(string: "--".appending(self.boundary.appending("--\r\n")), to: &body)

        return body
    }
}
