//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.URLSession

/**
 A Client is an abstraction over a URLSesson with an easy to use API to communicate with RESTful APIs
 */
public struct Client {

  // MARK: Initializers
  /**
   Initializer for a Client instance
   - parameter session: The URLSession to be used by the Client instance
   */
  public init(session: URLSession = URLSession.shared) {
    self.session = session
    session.configuration.httpAdditionalHeaders?["User-Agent"] = "ios:com.julio.alorro.Astral:v2.0.4"
  }

  // MARK: Properties
  /**
   The URLSession used to make http requests
   */
  private let session: URLSession

  // MARK: Functions
  /**
   Creates a request to the url with the specified http method
   - parameters:
      - url: The URL of the request
      - method: The http method of the request
   */
  public func request(url: String, method: HTTPMethod) throws -> RequestBuilder {
    return try RequestBuilder(session: self.session, url: url, method: method)
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
