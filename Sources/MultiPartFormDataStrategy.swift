//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
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
        self.files = request.files
    }

    // MARK: Stored Properties
    /**
     The defined boundary to be used in creating the multipart form-data HTTP body.
    */
    public let boundary: String

    /**
     The files to be uploaded in the http body
    */
    public let files: [FormFile]

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

    public func createHTTPBody(from parameters: Parameters) -> Data? {

        switch parameters {
            case .array, .none:
                return nil

            case .dict(let dict):
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

                for file in self.files {
                    self.append(string: boundaryPrefix, to: &body)
                    self.append(
                        string: "Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.fileName)\"\r\n",
                        to: &body
                    )

                    self.append(string: "Content-Type: \(file.contentType)\r\n\r\n", to: &body)

                    body.append(file.data)

                    self.append(string: "\r\n", to: &body)
                }

                self.append(string: "--\(self.boundary)--\r\n", to: &body)

                return body
        }
    }
}
