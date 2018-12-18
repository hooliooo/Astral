//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.NSObject
import struct Foundation.Data
import struct Foundation.URLRequest
import class Foundation.InputStream
import class Foundation.FileManager
import struct Foundation.URL
import func CoreFoundation.CFAbsoluteTimeGetCurrent
import class Foundation.OutputStream
import class Foundation.InputStream
import class Foundation.NSNumber
import struct Foundation.FileAttributeKey

/**
 An implementation of RequestBuilder that creates a URLRequest for multipart form data uploads.
 */
public class MultiPartFormDataBuilder: RequestBuilder {

    // MARK: Enums
    public enum WriteError: Swift.Error {
        case fileExists
        case couldNotCreateOutputStream
        case outputStreamWriteError(Error)
        case stringToDataFailed
    }

    public enum ReadError: Swift.Error {
        case couldNotCreateInputStream
        case inputStreamReadError(Error)
        case couldNotReadFileSize
    }

    // MARK: Initializer
    public init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }

    // MARK: Stored Properties
    public let fileManager: FileManager
    private let streamBufferSize: Int = 1_024

    public func urlRequest(of request: Request) -> URLRequest {
        return self._urlRequest(of: request)
    }

    public func multipartFormDataURLRequest(of request: MultiPartFormDataRequest) throws -> URLRequest {
        var urlRequest: URLRequest = self.urlRequest(of: request)
        let fileURL: URL = self.fileManager.ast.fileURL(of: request)
        try self.writeData(to: fileURL, for: request)

        guard let fileSize = try self.fileManager.attributesOfItem(atPath: fileURL.path)[FileAttributeKey.size] as? NSNumber else {
            throw MultiPartFormDataBuilder.ReadError.couldNotReadFileSize
        }

        urlRequest.addValue("\(fileSize.uint64Value)", forHTTPHeaderField: "Content-Length")

        urlRequest.httpBodyStream = InputStream(url: fileURL)
        return urlRequest
    }

    /**
     Creates the body of the multipart form data request. Loads the entire multipart form data into memory. This should
     only be used with requests that have a small memory footprint.
     - parameter request: The MultiPartFormDataRequest instance
    */
    public func data(of request: MultiPartFormDataRequest) throws -> Data {
        let strategy: MultiPartFormDataStrategy = MultiPartFormDataStrategy()
        let prefixData: Data = strategy.createHTTPBody(from: request.parameters)!
        let postfixData: Data = strategy.postfixData

        let start = CFAbsoluteTimeGetCurrent()

        var encodedData: Data = Data()
        encodedData.append(prefixData)

        for component in request.components {
            let boundaryPrefix: String = "--\(Astral.shared.boundary)\r\n"
            strategy.append(string: boundaryPrefix, to: &encodedData)
            strategy.append( // swiftlint:disable:next line_length
                string: "Content-Disposition: form-data; name=\"\(component.name)\"; filename=\"\(component.fileName)\"\r\n",
                to: &encodedData
            )

            strategy.append(string: "Content-Type: \(component.contentType)\r\n\r\n", to: &encodedData)

            switch component.file {
                case .data(let data):
                    encodedData.append(data)


                case .url(let url):
                    encodedData.append(try Data(contentsOf: url))
            }

            strategy.append(string: "\r\n", to: &encodedData)
        }

        encodedData.append(postfixData)

        let end = CFAbsoluteTimeGetCurrent()

        print((end - start) as Double)

        return encodedData
    }

    /**
     Creates the body of the multipart form data request by writing the entire multipart form data into a file. This method is very efficient,
     it utilizes input and output streams to read and write to a file. Should be used for large multipart form data.
     - parameter url: The URL of the file the multipart form data is written to
     - parameter request: The MultiPartFormDataRequest instance
     */
    public func writeData(to url: URL, for request: MultiPartFormDataRequest) throws {

        guard self.fileManager.fileExists(atPath: url.path) == false
            else { throw MultiPartFormDataBuilder.WriteError.fileExists }

        guard let outputStream = OutputStream(url: url, append: false)
            else { throw MultiPartFormDataBuilder.WriteError.couldNotCreateOutputStream }

        outputStream.open()
        defer { outputStream.close() }

        let strategy: MultiPartFormDataStrategy = MultiPartFormDataStrategy()
        let prefixData: Data = strategy.createHTTPBody(from: request.parameters)!
        let postfixData: Data = strategy.postfixData

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
                        else { throw MultiPartFormDataBuilder.ReadError.couldNotCreateInputStream }

                    inputStream = possibleStream
            }

            inputStream.open()
            defer { inputStream.close() }

            while inputStream.hasBytesAvailable {
                var buffer: [UInt8] = [UInt8](repeating: 0, count: self.streamBufferSize)
                let bytesRead: Int = inputStream.read(&buffer, maxLength: self.streamBufferSize)

                if let streamError = inputStream.streamError {
                    throw MultiPartFormDataBuilder.ReadError.inputStreamReadError(streamError)
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
                throw MultiPartFormDataBuilder.WriteError.outputStreamWriteError(streamError)
            }

            bytesToWrite -= bytesWritten

            if bytesToWrite > 0 {
                buffer = Array(buffer[bytesWritten..<buffer.count])
            }
        }
    }

    private func write(data: Data, to outputStream: OutputStream) throws {
        var buffer: [UInt8] = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &buffer, count: data.count)
        return try self.write(buffer: &buffer, to: outputStream)
    }

    private func write(string: String, to outputStream: OutputStream) throws {
        guard let stringData = string.data(using: String.Encoding.utf8) else {
            throw MultiPartFormDataBuilder.WriteError.stringToDataFailed
        }

        return try self.write(data: stringData, to: outputStream)
    }

}
