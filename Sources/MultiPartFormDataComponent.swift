//
//  Astral
//  Copyright (c) 2017-2019 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.Data
import struct Foundation.URL

/**
 A data structure representing a file to be sent as part of a multipart form-data request
*/
public struct MultiPartFormDataComponent {

    /**
     Represent the File either as Data or its URL in the file system.
    */
    public enum File: CustomStringConvertible, CustomDebugStringConvertible {
        /**
         Content of the file as Data.
        */
        case data(Data)

        /**
         URL of the file in the file system.
        */
        case url(URL)

        public var description: String {
            switch self {
                case .data(let data):
                    return data.description

                case .url(let url):
                    return url.description
            }
        }

        public var debugDescription: String {
            switch self {
                case .data(let data):
                    return data.debugDescription

                case .url(let url):
                    return url.debugDescription
            }
        }

    }

    /**
     Intializer of a FormData instance
     - parameter name: The name for the file to be used in the multipart form-data request
     - parameter fileName: Name of the file
     - parameter contentType: The mime type of the file
     - parameter data: Contents of the file
    */
    public init(name: String, fileName: String, contentType: String, file: MultiPartFormDataComponent.File) {
        self.name = name
        self.fileName = fileName
        self.contentType = contentType
        self.file = file
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
     The file as Data or its URL in the file system
    */
    public let file: MultiPartFormDataComponent.File

}

extension MultiPartFormDataComponent: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        return """
        Name: \(self.name)
        File name: \(self.fileName)
        Content type: \(self.contentType)
        File: \(self.file)
        """
    }

    public var debugDescription: String {
        return self.description
    }

}
