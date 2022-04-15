//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.InputStream
import class Foundation.FileManager
import class Foundation.OutputStream
import struct Foundation.Data
import struct Foundation.URL
import struct Foundation.UUID
import struct Foundation.FileAttributeKey

/**
 An implementation of DataStrategy specifically for creating an HTTP body for multipart form-data.
 */
public struct MultiPartFormBodyBuilder {

  // MARK: Initializer
  /**
   Initializer.
   */
  public init(fileManager: FileManager, boundary: String) {
    self.fileManager = fileManager
    self.boundary = boundary
  }

  // MARK: Instance Properties
  /**
   The FileManager used to create temporary multipart/form-data files in the cache directory
   */
  private let fileManager: FileManager
  /**
   The boundary used in creating the multipart/form-data
   */
  private let boundary: String
  private let streamBufferSize: Int = 1_024

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
   Creates the end part of the Data body needed for a multipart-form data HTTP Request.
   */
  internal var postfixData: Data {
    var data: Data = Data()
    self.append(string: "--\(self.boundary)--\r\n", to: &data)
    return data
  }

  /**
   Creates the body of the multipart form data request by writing the entire multipart form data into a file. This method is very efficient,
   it utilizes input and output streams to read and write to a file. Should be used for large multipart form data.
   - parameter url: The URL of the file the multipart form data is written to
   - parameter request: The MultiPartFormDataRequest instance
   */
  @discardableResult
  public func writeData(to url: URL, components: [MultiPartFormDataComponent]) throws -> UInt64 {

    guard self.fileManager.fileExists(atPath: url.path) == false
    else { throw MultiPartFormBodyBuilder.WriteError.fileExists }

    guard let outputStream = OutputStream(url: url, append: false)
    else { throw MultiPartFormBodyBuilder.WriteError.couldNotCreateOutputStream }

    outputStream.open()
    defer { outputStream.close() }

    for component in components {

      let boundaryPrefix: String = "--\(self.boundary)\r\n"
      try self.write(string: boundaryPrefix, to: outputStream)

      try self.write(
        string: "Content-Disposition: form-data; name=\"\(component.name)\";",
        to: outputStream
      )

      if case let .image(_, fileName, _, _) = component {
        try self.write(string: " filename=\"\(fileName)\"\r\n", to: outputStream)
      } else {
        try self.write(string: "\r\n", to: outputStream)
      }

      try self.write(string: "Content-Type: \"\(component.contentType)\"\r\n\r\n", to: outputStream)

      switch component {
        case let .image(_, _, _, file):
          let inputStream: InputStream
          switch file {
            case .data(let data):
              inputStream = InputStream(data: data)

            case .url(let url):
              guard let possibleStream = InputStream(url: url)
              else { throw MultiPartFormBodyBuilder.ReadError.couldNotCreateInputStream }

              inputStream = possibleStream
          }

          inputStream.open()
          defer { inputStream.close() }

          while inputStream.hasBytesAvailable {
            var buffer: [UInt8] = [UInt8](repeating: 0, count: self.streamBufferSize)
            let bytesRead: Int = inputStream.read(&buffer, maxLength: self.streamBufferSize)

            if let streamError = inputStream.streamError {
              throw MultiPartFormBodyBuilder.ReadError.inputStreamReadError(streamError)
            }

            guard bytesRead > 0 else { break }

            if buffer.count != bytesRead {
              buffer = Array(buffer[0..<bytesRead])
            }

            try self.write(buffer: &buffer, to: outputStream)
          }

        case .text, .json, .other:
          try self.write(string: "\(component.value)", to: outputStream)

      }

      try self.write(string: "\r\n", to: outputStream)
    }

    let postfixData: Data = self.postfixData

    try self.write(data: postfixData, to: outputStream)
    return (try self.fileManager.attributesOfItem(atPath: url.path)[FileAttributeKey.size] as? UInt64) ?? 0
  }


  // MARK: Private Write methods to OutputStream
  private func write(buffer: inout [UInt8], to outputStream: OutputStream) throws {
    var bytesToWrite: Int = buffer.count

    while bytesToWrite > 0, outputStream.hasSpaceAvailable {
      let bytesWritten: Int = outputStream.write(buffer, maxLength: bytesToWrite)

      if let streamError = outputStream.streamError {
        throw MultiPartFormBodyBuilder.WriteError.outputStreamWriteError(streamError)
      }

      bytesToWrite -= bytesWritten

      if bytesToWrite > 0 {
        buffer = Array(buffer[bytesWritten..<buffer.count])
      }
    }
  }

  private func write(string: String, to outputStream: OutputStream) throws {
    guard let stringData = string.data(using: String.Encoding.utf8) else {
      throw MultiPartFormBodyBuilder.WriteError.stringToDataFailed
    }
    return try self.write(data: stringData, to: outputStream)
  }

  private func write(data: Data, to outputStream: OutputStream) throws {
    var buffer: [UInt8] = [UInt8](repeating: 0, count: data.count)
    data.copyBytes(to: &buffer, count: data.count)
    return try self.write(buffer: &buffer, to: outputStream)
  }

}

// MARK: Public API Functions
public extension MultiPartFormBodyBuilder {

  func fileURL(for fileName: String) -> URL {
    return self.fileManager.ast.fileURL(with: fileName)
  }

}

// MARK: Enums
public extension MultiPartFormBodyBuilder {

  // MARK: Enums
  /**
   WriteError represents errors related to writing to or creating an OutputStream
   */
  enum WriteError: Swift.Error {
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
  enum ReadError: Swift.Error {
    /**
     The InputStream instance could not be initialized.
     */
    case couldNotCreateInputStream

    /**
     Reading an InputStream resulted in an error.
     */
    case inputStreamReadError(Error)

  }

}

// MARK: Old Implementations
private extension MultiPartFormBodyBuilder {

  //  /**
  //   Creates a Data instance based on the contents of MultiPartFormDataComponents. May throw an error.
  //   - parameter components: The MultiPartFormDataComponent instances.
  //   - returns: Data
  //   */
  //  internal func data(for components: [MultiPartFormDataComponent]) throws -> Data {
  //    var data: Data = Data()
  //
  //    for component in components {
  //      let boundaryPrefix: String = "--\(self.boundary)\r\n"
  //      self.append(string: boundaryPrefix, to: &data)
  //      self.append(
  //        string: "Content-Disposition: form-data; name=\"\(component.name)\";",
  //        to: &data
  //      )
  //
  //      if case let .image(_, fileName, _, _) = component {
  //        self.append(string: " filename=\"\(fileName)\"\r\n", to: &data)
  //      } else {
  //        self.append(string: "\r\n", to: &data)
  //      }
  //
  //      self.append(string: "Content-Type: \(component.contentType)\r\n\r\n", to: &data)
  //
  //      switch component {
  //        case let .image(_, _, _, file):
  //          switch file {
  //            case .data(let fileData):
  //              data.append(fileData)
  //
  //            case .url(let url):
  //              data.append(try Data(contentsOf: url))
  //          }
  //        case .text, .json, .other:
  //          self.append(string: "\(component.value)", to: &data)
  //
  //      }
  //
  //      self.append(string: "\r\n", to: &data)
  //    }
  //
  //    return data
  //  }

}
