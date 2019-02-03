//
//  Astral
//  Copyright (c) 2017-2019 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.FileManager

/**
 A MultiPartFormDataRequest is a type of Request used specifically for creating multipart form-data requests.
 It is designed to work with the MultipartFormDataStrategy struct to reduce boilerplate code, therefore is a convenience interface.
*/
public protocol MultiPartFormDataRequest: Request {

    /**
     The form data to be included in the multipart form data payload
    */
    var components: [MultiPartFormDataComponent] { get }

    /**
     File name used by the multipart data to be uploaded from the File system
     */
    var fileName: String { get }

}

public extension MultiPartFormDataRequest {

    var description: String {
        let string: String = self._description
        let componentDescriptions: String = self.components
            .map { (component: MultiPartFormDataComponent) -> String in
                return "\t" + component.description.replacingOccurrences(of: "\n", with: "\n\t")
            }
            .joined(separator: "\n\n")

        return """

        \(string)
        Components:
        \(componentDescriptions)
        File Name: \(self.fileName)

        """

    }

}
