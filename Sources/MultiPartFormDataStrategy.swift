//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.Data
import struct Foundation.URL
import class Foundation.InputStream
import class Foundation.FileManager
import class Foundation.OutputStream

/**
 An implementation of DataStrategy specifically for creating an HTTP body for multipart form-data.
*/
public struct MultiPartFormDataStrategy {

    // MARK: Enums
    /**
     WriteError represents errors related to writing to or creating an OutputStream
    */
    public enum WriteError: Swift.Error {
        /**
         The file already exists at the URL.
        */
        case fileExists

        /**
         The OutputStream instance could not be initialized.
        */
        case couldNotCreateOutputStream

        /**
         Writing to the OutputStream resulted in an error.
        */
        case outputStreamWriteError(Error)

        /**
         The String instance could not be transformed into a Data instance.
        */
        case stringToDataFailed
    }

    /**
     ReadError represents errors related to reading or creating an InputStream or reading a file's attributes.
    */
    public enum ReadError: Swift.Error {
        /**
         The InputStream instance could not be initialized.
        */
        case couldNotCreateInputStream

        /**
         Reading an InputStream resulted in an error.
        */
        case inputStreamReadError(Error)

    }

    // MARK: Initializer
    /**
     Initializer.
    */
    public init() {}

    // MARK: Instance Properties
    private let streamBufferSize: Int = 1_024

    // MARK: Computed Properties
    /**
     The FileManager used to write/read from the file system. The default value is the FileManager from the Astral singleton.
    */
    public var fileManager: FileManager {
        return Astral.shared.fileManager
    }

    // MARK: Instance Methods
    /**
     The method used to modify the HTTP body to create the multipart form-data payload.
     - parameter string: The string to be converted into Data.
     - parameter data: The data the string will be appended to.
    */
    private func append(string: String, to data: inout Data) {
        let stringData: Data = string.data(using: String.Encoding.utf8)! // swiftlint:disable:this force_unwrapping
        data.append(stringData)
    }

    /**
     Creates the beginning part of the Data body needed for a multipart-form data HTTP Request.
     - parameter request: The MultiPartFormDataRequest instance.
     - returns: Data
    */
    private func prefixData(for request: MultiPartFormDataRequest) -> Data {
        var data: Data = Data()

        let boundaryPrefix: String = "--\(Astral.shared.boundary)\r\n"

        switch request.parameters {
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
                            let value: String = String(describing: value)
                            self.append(string: "\(value)", to: &data)
                            self.append(string: "\r\n", to: &data)
                        }
                }
        }

        return data
    }

    /**
     Creates a Data instance based on the contents of MultiPartFormDataComponents. May throw an error.
     - parameter components: The MultiPartFormDataComponent instances.
     - returns: Data
    */
    private func data(for components: [MultiPartFormDataComponent]) throws -> Data {
        var data: Data = Data()

        for component in components {
            let boundaryPrefix: String = "--\(Astral.shared.boundary)\r\n"
            self.append(string: boundaryPrefix, to: &data)
            self.append(
                string: "Content-Disposition: form-data; name=\"\(component.name)\"; filename=\"\(component.fileName)\"\r\n",
                to: &data
            )

            self.append(string: "Content-Type: \(component.contentType)\r\n\r\n", to: &data)

            switch component.file {
                case .data(let fileData):
                    data.append(fileData)

                case .url(let url):
                    data.append(try Data(contentsOf: url))
            }

            self.append(string: "\r\n", to: &data)
        }

        return data
    }

    /**
     Creates the end part of the Data body needed for a multipart-form data HTTP Request.
    */
    private var postfixData: Data {
        var data: Data = Data()
        self.append(string: "--\(Astral.shared.boundary)--\r\n", to: &data)
        return data
    }

    /**
     Creates the body of the multipart form data request by writing the entire multipart form data into a file. This method is very efficient,
     it utilizes input and output streams to read and write to a file. Should be used for large multipart form data.
     - parameter url: The URL of the file the multipart form data is written to
     - parameter request: The MultiPartFormDataRequest instance
     */
    public func writeData(to url: URL, for request: MultiPartFormDataRequest) throws {

        guard self.fileManager.fileExists(atPath: url.path) == false
            else { throw MultiPartFormDataStrategy.WriteError.fileExists }

        guard let outputStream = OutputStream(url: url, append: false)
            else { throw MultiPartFormDataStrategy.WriteError.couldNotCreateOutputStream }

        outputStream.open()
        defer { outputStream.close() }

        let prefixData: Data = self.prefixData(for: request)
        let postfixData: Data = self.postfixData

        try self.write(data: prefixData, to: outputStream)

        for component in request.components {

            let boundaryPrefix: String = "--\(Astral.shared.boundary)\r\n"
            try self.write(string: boundaryPrefix, to: outputStream)
            try self.write(
                string: "Content-Disposition: form-data; name=\"\(component.name)\"; filename=\"\(component.fileName)\"\r\n",
                to: outputStream
            )

            try self.write(string: "Content-Type: \(component.contentType)\r\n\r\n", to: outputStream)

            let inputStream: InputStream

            switch component.file {
                case .data(let data):
                    inputStream = InputStream(data: data)

                case .url(let url):
                    guard let possibleStream = InputStream(url: url)
                        else { throw MultiPartFormDataStrategy.ReadError.couldNotCreateInputStream }

                    inputStream = possibleStream
            }

            inputStream.open()
            defer { inputStream.close() }

            while inputStream.hasBytesAvailable {
                var buffer: [UInt8] = [UInt8](repeating: 0, count: self.streamBufferSize)
                let bytesRead: Int = inputStream.read(&buffer, maxLength: self.streamBufferSize)

                if let streamError = inputStream.streamError {
                    throw MultiPartFormDataStrategy.ReadError.inputStreamReadError(streamError)
                }

                guard bytesRead > 0 else { break }

                if buffer.count != bytesRead {
                    buffer = Array(buffer[0..<bytesRead])
                }

                try self.write(buffer: &buffer, to: outputStream)
            }

            try self.write(string: "\r\n", to: outputStream)
        }

        try self.write(data: postfixData, to: outputStream)

    }

    // MARK: Private Write methods to OutputStream
    private func write(buffer: inout [UInt8], to outputStream: OutputStream) throws {
        var bytesToWrite: Int = buffer.count

        while bytesToWrite > 0, outputStream.hasSpaceAvailable {
            let bytesWritten: Int = outputStream.write(buffer, maxLength: bytesToWrite)

            if let streamError = outputStream.streamError {
                throw MultiPartFormDataStrategy.WriteError.outputStreamWriteError(streamError)
            }

            bytesToWrite -= bytesWritten

            if bytesToWrite > 0 {
                buffer = Array(buffer[bytesWritten..<buffer.count])
            }
        }
    }

    private func write(string: String, to outputStream: OutputStream) throws {
        guard let stringData = string.data(using: String.Encoding.utf8) else {
            throw MultiPartFormDataStrategy.WriteError.stringToDataFailed
        }
        return try self.write(data: stringData, to: outputStream)
    }

    private func write(data: Data, to outputStream: OutputStream) throws {
        var buffer: [UInt8] = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &buffer, count: data.count)
        return try self.write(buffer: &buffer, to: outputStream)
    }

}

// MARK: - DataStrategy Methods
extension MultiPartFormDataStrategy: DataStrategy {

    /**
     Transforms the multipart form data of the MultiPartFormDataRequest into Data by loading it all into memory.
     Only use this method if the form data has a small memory footprint.
     - parameter request: The MultiPartFormDataRequest instance. If this is not a MultiPartFormDataRequest type, returns nil.
     - returns: Data, may return nil if the Request instance is not a MultiPartFormDataRequest
    */
    public func createHTTPBody(from request: Request) -> Data? {
        guard
            let request = request as? MultiPartFormDataRequest,
            let bodyData = try? self.data(for: request.components)
        else {
            return nil
        }

        var data: Data = Data()
        data.append(self.prefixData(for: request))
        data.append(bodyData)
        data.append(self.postfixData)

        return data
    }
}

// MARK: Public API Functions
public extension MultiPartFormDataStrategy {
    /**
     Creates a URL based on the MultiPartFormDataRequest's fileName.
     - parameter request: The MultiPartFormDataRequest instance.
     - returns: URL
    */
    func fileURL(for request: MultiPartFormDataRequest) -> URL {
        return self.fileManager.ast.fileURL(of: request)
    }

    /**
     Writes the multipart form data of the MultiPartFormDataRequest into a file and creates an InputStream pointing the fileURL.
     This method is very efficient, therefore can be used for large data sets.
     - parameters:
        - request: The MultiPartFormDataRequest instance.
        - fileURL: The URL of the file the InputStream will point to.
     - returns: InputStream
    */
    func createHTTPStreamBody(from request: MultiPartFormDataRequest, at fileURL: URL) throws -> InputStream {
        try self.writeData(to: fileURL, for: request)
        guard let inputStream = InputStream(url: fileURL) else {
            throw MultiPartFormDataStrategy.ReadError.couldNotCreateInputStream
        }

        return inputStream
    }
}
