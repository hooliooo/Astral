//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.FileManager
import class Foundation.InputStream
import class Foundation.JSONDecoder
import class Foundation.JSONEncoder
import class Foundation.JSONSerialization
import class Foundation.OutputStream
import class Foundation.URLResponse
import class Foundation.URLSession
import struct Foundation.CharacterSet
import struct Foundation.Data
import struct Foundation.URL
import struct Foundation.URLComponents
import struct Foundation.URLQueryItem
import struct Foundation.URLRequest
import struct Foundation.UUID

/**
 A RequestBuilder constructs the properties of a URLRequest
 */
public struct RequestBuilder {

  // MARK: Stored Properties
  /**
   The FileManager used to create temporary multipart/form-data fiels in the cache directory
   */
  private let fileManager: FileManager
  /**
   The URLSession used to make an http request with the constructed URLRequest
   */
  private let session: URLSession
  /**
   The components that make up the url of the URLRequest
   */
  public var urlComponents: URLComponents
  /**
   The URLRequest instance modified by the methods of the RequestBuilder and sent using the send methods
   */
  public var request: URLRequest
  /**
   The url to the file being uploaded by the URLSession as a stream
   */
  private var fileURL: URL?

  // MARK: Initializers
  /**
   The initialer of the RequestBuilder
   - parameters:
      - session: The URLSesson used to send the URLRequest
      - fileManager: The FileManager used to create temporary multipart/form-data fiels in the cache directory
      - url: The url of the URLRequest
      - method: The http method of the URLRequest
   */
  public init(session: URLSession, fileManager: FileManager, url: String, method: HTTPMethod) throws {
    guard
      let components = URLComponents(string: url),
      let url = components.url
    else {
      throw Error.invalidURL
    }
    self.session = session
    self.fileManager = fileManager
    self.urlComponents = components
    self.request = URLRequest(url: url)
    self.request.httpMethod = method.stringValue
  }

  // MARK: Private Functions
  /**
   Convenience method used under the hood to make a fluent API when building the URLRequest via the RequestBuilder
   - parameter changes: The closure used to mutate the RequestBuilder. Returns a new RequestBuilder with the changes.
   */
  private func copy(with changes: (inout RequestBuilder) throws -> Void) rethrows -> RequestBuilder {
    var mutableSelf = self
    try changes(&mutableSelf)
    return mutableSelf
  }

  // MARK: Authentication Functions
  /**
   Adds Basic Authentication to the URLRequest
   - parameters:
      - username: The username for the Basic Authentication header
      - password: The password for the Basic Authentication header
   */
  public func basicAuthentication(username: String, password: String) throws -> RequestBuilder {
    guard let token = "\(username):\(password)".data(using: String.Encoding.utf8)?.base64EncodedString() else {
      throw Error.invalidToken
    }
    return self.headers(headers: [Header(key: Header.Key.authorization, value: Header.Value.basicAuthorization(token))])
  }

  /**
   Adds Bearer token Authentication to the URLRequest
   - parameter token: The token for the Bearer Authentication header
   */
  public func bearerAuthentication(token: String) -> RequestBuilder {
    return self.headers(headers: [Header(key: Header.Key.authorization, value: Header.Value.custom("Bearer \(token)"))])
  }

  // MARK: Body Functions
  /**
   Adds a body to the URLRequest and sets the Content-Type to the specified Media Type
   - parameters:
      - data: The data to be added as the body to the URLRequest
      - medtiaType: The media type of the data added as the Content-Type header
   */
  public func body(data: Data, mediaType: MediaType) -> RequestBuilder {
    return self.copy { $0.request.httpBody = data }
      .headers(headers: [Header(key: Header.Key.contentType, value: Header.Value.mediaType(mediaType))])
  }

  // MARK: Form URL Encoded Functions
  /**
   Adds a url encoded form body to the URLRequest and sets the Content-Type to application/x-www-form-urlencoded
   - parameter items: The form data to be url encoded as the body
   */
  public func form(items: [URLQueryItem]) -> RequestBuilder {
    return self.copy {
      $0.request.httpBody = items.compactMap { (item: URLQueryItem) -> String? in
        guard
          let value = item.value,
          let urlEncodedValue = value.addingPercentEncoding(withAllowedCharacters: RequestBuilder.urlEncodedSet)
        else { return nil }
        return "\(item.name)=\(urlEncodedValue)"
      }
      .joined(separator: "&")
      .data(using: String.Encoding.utf8)
    }
    .headers(headers: [Header(key: Header.Key.contentType, value: Header.Value.mediaType(MediaType.applicationURLEncoded))])
  }

  // MARK: Header Function
  /**
   Adds headers to the URLRequest
   - parameter headers: The headers to be added to the URLRequest
   */
  public func headers(headers: Set<Header>) -> RequestBuilder {
    return self.copy { (builder: inout RequestBuilder) -> Void in
      headers.forEach {
        builder.request.addValue($0.value.stringValue, forHTTPHeaderField: $0.key.stringValue)
      }
    }
  }

  // MARK: JSON Functions
  /**
   Adds a JSON body to the URLRequest and specifieds the Content-Type header as application/json
   - parameters:
      - body: The Encodable object to be serialized as the JSON body of the URLRequest.
      - encoder: THe JSONEncoder that transforms the body object into JSON data
   */
  public func json<T: Encodable>(body: T, encoder: JSONEncoder = JSONEncoder()) throws -> RequestBuilder {
    let data: Data = try encoder.encode(body)
    return self.body(data: data, mediaType: MediaType.applicationJSON)
  }

  /**
   Adds a JSON body to the URLRequest and specifieds the Content-Type header as application/json
   - parameter body: The Encodable object to be serialized as the JSON body of the URLRequest.
   */
  public func json(body: Any) throws -> RequestBuilder {
    let data = try JSONSerialization.data(withJSONObject: body)
    return self.body(data: data, mediaType: MediaType.applicationJSON)
  }

  // MARK: Multipart Function
  /**
   Adds a multipart/form-data body to the URLRequest as an httpBodyStream
   - parameter components: The parts of used to create multipart/form-data request body
   */
  public func multipart(components: [MultiPartFormDataComponent], boundary: String = UUID().uuidString) throws -> RequestBuilder {
    let strategy: MultiPartFormBodyBuilder = MultiPartFormBodyBuilder(
      fileManager: self.fileManager,
      boundary: boundary
    )
    let fileName: UUID = UUID()
    let url: URL = strategy.fileURL(for: fileName.uuidString)
    let fileSize: UInt64 = try strategy.writeData(to: url, components: components)
    guard let inputStream = InputStream(url: url) else {
      throw MultiPartFormBodyBuilder.ReadError.couldNotCreateInputStream
    }
    return self.copy {
      $0.fileURL = url
      $0.request.httpBodyStream = inputStream
    }
    .headers(
      headers: [
        Header(key: Header.Key.contentType, value: Header.Value.mediaType(MediaType.multipartFormData(boundary))),
        Header(key: Header.Key.custom("Content-Length"), value: Header.Value.custom(fileSize.description))
      ]
    )
  }

  // MARK: Query Function
  /**
   Adds query items to the URL of the URLRequst
    - parameter items: The URLQueryItems to be added to the URL of the URLRequest
   */
  public func query(items: [URLQueryItem]) -> RequestBuilder {
    var components = self.urlComponents
    components.queryItems = items
    return self.copy {
      $0.urlComponents = components
      $0.request.url = components.url
    }
  }

  // MARK: Send Functions
  /**
   Cleans up the file used to aggregate a multipart/form-data request into a stream
   */
  private func cleanUpMultipartStream() throws {
    guard let url = self.fileURL else { return }
    try self.fileManager.removeItem(at: url)
  }

  /**
   Sends the URLRequest and decodes the response into a Data instance. Also cleans up the multipart/form-data file created
   if there is one.
   */
  public func send() async throws -> (Data, URLResponse) {
    defer { try? self.cleanUpMultipartStream() }
    do {
      return try await self.session.data(for: self.request)
    } catch {
      throw error
    }
  }

  /**
   Sends the URLRequest and decodes the response into a Decodable object
  - parameter decoder: THe JSONDecoder used to deserialize the response into the specified object
   */
  public func send<T: Decodable>(decoder: JSONDecoder = JSONDecoder()) async throws -> (T, URLResponse) {
    let (data, response): (Data, URLResponse) = try await self.send()
    return (try decoder.decode(T.self, from: data), response)
  }

  /**
   Sends the URLRequest and decodes the response into a String instance
   */
  public func send() async throws -> (String, URLResponse) {
    let (data, response): (Data, URLResponse) = try await self.send()
    return (String(data: data, encoding: String.Encoding.utf8)!, response)
  }

  /**
   Sends the URLRequest and decodes the response into an Any instance
   */
  public func send() async throws -> (Any, URLResponse) {
    let (data, response): (Data, URLResponse) = try await self.send()
    return (try JSONSerialization.jsonObject(with: data), response)
  }

}

public extension RequestBuilder {

  /**
   Represents the possible errors that can occur while mutating the RequestBuilder
   */
  enum Error: Swift.Error {
    /**
     Error thrown when the URL created isn't valid
     */
    case invalidURL
    /**
     Error thrown when the base64 encoding of the token of the Basic Authentication fails
     */
    case invalidToken
  }

  /**
   The character set used to url encode form values for a application/x-www-form-urlencoded URLRequest
   */
  static let urlEncodedSet: CharacterSet = {
    var set: CharacterSet = CharacterSet.alphanumerics
    set.insert(charactersIn: "-._* ")
    return set
  }()

}
