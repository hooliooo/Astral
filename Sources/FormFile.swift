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
    public init(name: String, fileName: String, contentType: String, data: Data) {
        self.name = name
        self.fileName = fileName
        self.contentType = contentType
        self.data = data
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

}
