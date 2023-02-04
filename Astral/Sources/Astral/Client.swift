//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.Bundle
import class Foundation.FileManager
import class Foundation.URLSession
import class Foundation.URLSessionConfiguration
import struct os.Logger

/**
 A Client is an abstraction over a URLSession with an easy to use API to communicate with RESTful APIs
 */
public struct Client {

  // MARK: Initializers
  /**
   Initializer for a Client instance
   - parameters:
      - fileManager: The FileManager used to create temporary multipart/form-data files in the cache directory
      - session: The URLSession to be used by the Client instance
   */
  public init(fileManager: FileManager, session: URLSession) {
    self.fileManager = fileManager
    self.session = session
  }

  /**
   Convenience initializer that creates a URLSession configured with a User-Agent in the following format:
   "\(bundleIdentifier), buildVersion:\(appBuild), version:\(appShortVersion) Astral/v3.0.0" and
   the Filemanager.default singleton
   */
  public init() {
    let configuration: URLSessionConfiguration = .default
    let info: [String: Any] = Bundle.main.infoDictionary ?? [:]
    let bundleIdentifier = info["CFBundleIdentifier"] as? String ?? "Unknown Identifier"
    let appBuild = info["CFBundleVersion"] as? String ?? "Unknown Bundle Version"
    let appShortVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown Short Version"
    configuration.httpAdditionalHeaders = [
      "User-Agent": "\(bundleIdentifier), buildVersion:\(appBuild), version:\(appShortVersion) Astral/v3.0.0"
    ]
    let session: URLSession = URLSession(configuration: configuration)
    self.init(fileManager: FileManager.default, session: session)
  }

  // MARK: Properties
  /**
   The URLSession used to make http requests
   */
  public let session: URLSession

  /**
   The FileManager used to create temporary multipart/form-data files in the cache directory
   */
  public let fileManager: FileManager

  /**
   The logger for the client
   */
  public let logger: Logger = Logger(subsystem: "Astral", category: "Client")

  // MARK: Functions
  /**
   Creates a request to the url with the specified http method
   - parameters:
      - url: The URL of the request
      - method: The http method of the request
   */
  public func request(url: String, method: HTTPMethod) throws -> RequestBuilder {
    return try RequestBuilder(session: self.session, fileManager: self.fileManager, url: url, method: method)
  }

  /**
   A convenience method to make a GET request to the URL
    - parameter url: The URL of the GET request
   */
  public func get(url: String) throws -> RequestBuilder {
    return try self.request(url: url, method: HTTPMethod.get)
  }

  /**
   A convenience method to make a DELETE request to the URL
    - parameter url: The URL of the DELETE request
   */
  public func delete(url: String) throws -> RequestBuilder {
    return try self.request(url: url, method: HTTPMethod.delete)
  }

  /**
   A convenience method to make a POST request to the URL
    - parameter url: The URL of the POST request
   */
  public func post(url: String) throws -> RequestBuilder {
    return try self.request(url: url, method: HTTPMethod.post)
  }

  /**
   A convenience method to make a PUT request to the URL
    - parameter url: The URL of the PUT request
   */
  public func put(url: String) throws -> RequestBuilder {
    return try self.request(url: url, method: HTTPMethod.put)
  }

}
