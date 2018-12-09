//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.Data

/**
 An implementation of DataStrategy specifically for creating an HTTP body for multipart form-data.
*/
public struct MultiPartFormDataStrategy {

    // MARK: Initializer
    /**
     Initializer.
    */
    public init() {}

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

    /**
     Creates the end part of the Data body needed for a multipart-form data HTTP Request.
    */
    public var postfixData: Data {
        var data: Data = Data()
        self.append(string: "--\(Astral.shared.boundary)--\r\n", to: &data)
        return data
    }

}

// MARK: - DataStrategy Methods
extension MultiPartFormDataStrategy: DataStrategy {

    /**
     Creates the beginning part of the Data body needed for a multipart-form data HTTP Request.
     - parameter parameters: The Parameters instance used to create the beginning part of the Data body.
    */
    public func createHTTPBody(from parameters: Parameters) -> Data? {

        var data: Data = Data()

        let boundaryPrefix: String = "--\(Astral.shared.boundary)\r\n"

        switch parameters {
            case .array, .none:
                break

            case .dict(let dict):
                switch dict.isEmpty {
                    case true:
                        break

                    case false:
                        for (key, value) in dict {
                            self.append(string: boundaryPrefix, to: &data)
                            self.append(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n", to: &data)
                            //                            self.append(string: "Content-Type: text/plain\r\n", to: &data)
                            let value: String = String(describing: value)
                            self.append(string: "\(value)", to: &data)
                            self.append(string: "\r\n", to: &data)
                        }
                }
        }

        return data
    }
}
