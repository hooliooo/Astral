//
//  Astral
//  Copyright (c) 2017 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 A MultiPartFormDataRequest is a type of Request used specifically for creating multipart form-data requests.
 It is designed to work with the MultipartFormDataStrategy struct to reduce boilerplate code, therefore is a convenience interface.
*/
public protocol MultiPartFormDataRequest: Request {

    /**
     The boundary string to be used when constructing the multipart form-data payload
    */
    var boundary: String { get }

    /**
     The data to be included in the multipart form-data payload
    */
    var data: Data { get }

    /**
     The file name to be used as part of the multipart form-data payload.
    */
    var fileName: String { get }

    /**
     The mime type to be defined as the Content-Type in the multipart form-data payload.
    */
    var mimeType: String { get }

}

public extension MultiPartFormDataRequest {

    var description: String {
        let strings: [String] = [
            "Method: \(self.method)",
            "PathComponents: \(self.pathComponents)",
            "Parameters: \(self.parameters)",
            "Headers: \(self.headers)",
            "Boundary: \(self.boundary)",
            "fileName: \(self.fileName)",
            "mimeType: \(self.mimeType)"
        ]

        let description: String = strings.reduce(into: "") { (result: inout String, string: String) -> Void in
            result = "\(result)\n\t\(string)"
        }

        return "Type: \(type(of: self)): \(description)"
    }

    var debugDescription: String {
        return self.description
    }

}