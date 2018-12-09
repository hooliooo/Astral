//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.Data

/**
 A data structure representing a file to be sent as part of a multipart form-data request
*/
public struct FormFile {

    /**
     Intializer of a FormData instance
     - parameter name: The name for the file to be used in the multipart form-data request
     - parameter fileName: Name of the file
     - parameter contentType: The mime type of the file
     - parameter data: Contents of the file
    */
    public init(name: String, fileName: String, contentType: String, data: Data, parameters: Parameters) {
        self.name = name
        self.fileName = fileName
        self.contentType = contentType
        self.data = data
        self.parameters = parameters
    }

    // MARK: Stored Properties
    /**
     The name for the file in the multipart form data
    */
    public let name: String

    /**
     The file's name
    */
    public let fileName: String

    /**
     The mime type of the file
    */
    public let contentType: String

    /**
     The contents of the file
    */
    public let data: Data

    public let parameters: Parameters

    public var bodyData: Data {
        let boundaryPrefix: String = "--\(Astral.shared.boundary)\r\n"
        var data: Data = Data()

        self.append(string: boundaryPrefix, to: &data)
        self.append(
            string: "Content-Disposition: form-data; name=\"\(self.name)\"; filename=\"\(self.fileName)\"\r\n",
            to: &data
        )

        self.append(string: "Content-Type: \(self.contentType)\r\n\r\n", to: &data)
        data.append(self.data)
        self.append(string: "\r\n", to: &data)
        return data
    }

    private func append(string: String, to data: inout Data) {
        let stringData: Data = string.data(using: String.Encoding.utf8)!
        data.append(stringData)
    }

}
