//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 A RequestBuilder constructs the properties of a URLRequest
 */
public struct RequestBuilder {

  // MARK: Stored Properties
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
      - url: The url of the URLRequest
      - method: The http method of the URLRequest
   */
  public init(session: URLSession, url: String, method: HTTPMethod) throws {
    guard
      let components = URLComponents(string: url),
      let url = components.url
    else {
      throw Error.invalidURL
    }
    self.session = session
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

  /**
   Convenience method to set headers appropriately for simple JSON http requests
   */
  private func setHttpHeadersForJSON() -> RequestBuilder {
    return self.copy {
      $0.request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      $0.request.addValue("application/json", forHTTPHeaderField: "Accept")
    }
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
      throw Error.invalidDataConversion
    }
    return self.copy {
      $0.request.addValue("Basic \(token)", forHTTPHeaderField: "Authorization")
    }
  }

  /**
   Adds Bearer token Authentication to the URLRequest
   - parameter token: The token for the Bearer Authentication header
   */
  public func bearerAuthentication(token: String) -> RequestBuilder {
    return self.copy {
      $0.request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
  }

  // MARK: Body Functions
  public func body(data: Data, mediaType: MediaType) -> RequestBuilder {
    return self
      .copy {
        $0.request.httpBody = data
        $0.request.addValue(mediaType.stringValue, forHTTPHeaderField: "Content-Type")
      }
  }

  // MARK: JSON Functions
  public func json<T: Encodable>(body: T, encoder: JSONEncoder = JSONEncoder()) throws -> RequestBuilder {
    let data: Data = try encoder.encode(body)
    return self.body(data: data, mediaType: MediaType.applicationJSON)
  }

  public func json(body: Any) throws -> RequestBuilder {
    let data = try JSONSerialization.data(withJSONObject: body)
    return self.body(data: data, mediaType: MediaType.applicationJSON)
  }

  // MARK: Form URL Encoded Functions
  public func form(items: [URLQueryItem]) -> RequestBuilder {
    return self.copy {
      $0.request.httpBody = items.compactMap { (item: URLQueryItem) -> String? in
        guard
          let value = item.value,
          let urlEncodedValue = value.addingPercentEncoding(withAllowedCharacters: RequestBuilder.characterSet)
        else { return nil }
        return "\(item.name)=\(urlEncodedValue)"
      }
      .joined(separator: "&")
      .data(using: String.Encoding.utf8)

      $0.request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    }
  }

  // MARK: Header Function
  public func headers(headers: Set<Header>) -> RequestBuilder {
    return self.copy { (builder: inout RequestBuilder) -> Void in
      headers.forEach {
        builder.request.addValue($0.value.stringValue, forHTTPHeaderField: $0.key.stringValue)
      }
    }
  }

  // MARK: Multipart Function
  public func multipart(components: [MultiPartFormDataComponent]) throws -> RequestBuilder {
    let strategy: MultiPartFormDataStrategy = MultiPartFormDataStrategy()
    let fileName: UUID = UUID()
    let url: URL = strategy.fileURL(for: fileName.uuidString)
    let fileSize: UInt64 = try strategy.writeData(to: url, components: components)
    guard let inputStream = InputStream(url: url) else {
      throw MultiPartFormDataStrategy.ReadError.couldNotCreateInputStream
    }
    return self.copy {
      $0.fileURL = url
      $0.request.httpBodyStream = inputStream
      $0.request.addValue("multipart/form-data; boundary=\(Astral.shared.boundary)", forHTTPHeaderField: "Content-Type")
      $0.request.addValue(fileSize.description, forHTTPHeaderField: "Content-Length")
    }
  }

  // MARK: Query Function
  public func query(items: [URLQueryItem]) -> RequestBuilder {
    var components = self.urlComponents
    components.queryItems = items
    return self
      .copy {
        $0.urlComponents = components
        $0.request.url = components.url
      }
      .setHttpHeadersForJSON()
  }

  // MARK: Send Functions
  private func cleanUpMultipartStream() throws {
    guard let url = self.fileURL else { return }
    try Astral.shared.fileManager.removeItem(at: url)
  }

  private func executeCatchingErrors<T>(block: () async throws -> T) async rethrows -> T {
    defer { try? self.cleanUpMultipartStream() }
    do {
      return try await block()
    } catch {
      throw error
    }
  }

  public func send<T: Decodable>(decoder: JSONDecoder = JSONDecoder()) async throws -> (T, URLResponse) {
    return try await self.executeCatchingErrors {
      let (data, response) = try await self.session.data(for: self.request)
      return (try decoder.decode(T.self, from: data), response)
    }
  }

  public func send() async throws -> (String, URLResponse) {
    return try await self.executeCatchingErrors {
      let (data, response) = try await self.session.data(for: self.request)
      return (String(data: data, encoding: String.Encoding.utf8)!, response)
    }
  }

  public func send() async throws -> (Any, URLResponse) {
    return try await self.executeCatchingErrors {
      let (data, response) = try await self.session.data(for: self.request)
      return (try JSONSerialization.jsonObject(with: data), response)
    }
  }

}

public extension RequestBuilder {

  enum Error: Swift.Error {
    case invalidURL
    case invalidDataConversion
  }

  static let characterSet: CharacterSet = {
    var set: CharacterSet = CharacterSet.alphanumerics
    set.insert(charactersIn: "-._* ")
    return set
  }()

}
