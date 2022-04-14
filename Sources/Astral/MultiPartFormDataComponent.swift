//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.Data
import struct Foundation.URL

/**
 A data structure representing a file to be sent as part of a multipart form-data request
*/
public enum MultiPartFormDataComponent {

  case image(name: String, fileName: String, contentType: String, file: MultiPartFormDataComponent.File)
  case json(name: String, payload: Any)
  case text(name: String, value: String)
  case other(name: String, value: Any, contentType: String)

  public var name: String {
    switch self {
      case .image(let name, _, _, _), .json(let name, _), .text(let name, _), .other(let name, _, _):
        return name
    }
  }

  public var contentType: String {
    switch self {
      case let .image(_, _, contentType, _), let .other(_, _, contentType): return contentType
      case .json: return "application/json"
      case .text: return "text/plain"
    }
  }

  public var value: String {
    switch self {
      case let .image(_, _, _, file): return file.description
      case let .other(_, value, _): return String(describing: value)
      case let .json(_, value): return String(describing: value)
      case let .text(_, value): return value
    }
  }

}

public extension MultiPartFormDataComponent {
  /**
   Represent the File either as Data or its URL in the file system.
  */
  enum File: CustomStringConvertible, CustomDebugStringConvertible {
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

}
