//
//  APIClient.swift
//  
//
//  Created by Julio Alorro on 08.04.22.
//

import Foundation

public struct APIClient {

  // MARK: Initializers
  public init() {
    self.session = {
      let configuration: URLSessionConfiguration = URLSessionConfiguration.default
      configuration.timeoutIntervalForRequest = 20.0
      configuration.timeoutIntervalForResource = 20.0
      configuration.httpAdditionalHeaders = ["User-Agent": "ios:com.julio.alorro.Astral:v2.0.4"]

      let session: URLSession = URLSession(configuration: configuration)
      return session
    }()
  }

  // MARK: Properties
  private let session: URLSession

  // MARK: Functions
  public func custom(url: String, method: String) throws -> RequestBuilder2 {
    return try RequestBuilder2(session: self.session, url: url, method: HTTPMethod.other(method).stringValue)
  }

  public func get(url: String) throws -> RequestBuilder2 {
    return try RequestBuilder2(session: self.session, url: url, method: HTTPMethod.get.stringValue)
  }

  public func delete(url: String) throws -> RequestBuilder2 {
    return try RequestBuilder2(session: self.session, url: url, method: HTTPMethod.delete.stringValue)
  }

  public func post(url: String) throws -> RequestBuilder2 {
    return try RequestBuilder2(session: self.session, url: url, method: HTTPMethod.post.stringValue)
  }

  public func put(url: String) throws -> RequestBuilder2 {
    return try RequestBuilder2(session: self.session, url: url, method: HTTPMethod.put.stringValue)
  }

}

public struct RequestBuilder2 {

  // MARK: Stored Properties
  private let session: URLSession
  public var urlComponents: URLComponents
  public var request: URLRequest
  private var fileURL: URL?

  // MARK: Initializers
  public init(session: URLSession, url: String, method: String) throws {

    guard
      let components = URLComponents(string: url),
      let url = components.url
    else {
      throw Error.invalidURL
    }
    self.session = session
    self.urlComponents = components
    self.request = URLRequest(url: url)
    self.request.httpMethod = method
  }

  private func copy(with changes: (inout RequestBuilder2) throws -> Void) rethrows -> RequestBuilder2 {
    var mutableSelf = self
    try changes(&mutableSelf)
    return mutableSelf
  }

  // MARK: Authentication Functions
  public func basicAuthentication(username: String, password: String) throws -> RequestBuilder2 {
    guard let token = "\(username):\(password)".data(using: String.Encoding.utf8)?.base64EncodedString() else {
      throw Error.invalidDataConversion
    }
    return self.copy {
      $0.request.addValue("Basic \(token)", forHTTPHeaderField: "Authorization")
    }
  }

  public func bearerAuthentication(token: String) -> RequestBuilder2 {
    return self.copy {
      $0.request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
  }

  // MARK: Body Functions
  @discardableResult
  private func setHttpHeadersForJSON() -> RequestBuilder2 {
    return self.copy {
      $0.request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      $0.request.addValue("application/json", forHTTPHeaderField: "Accept")
    }
  }

  public func body<T: Encodable>(body: T) throws -> RequestBuilder2 {
    return try self
      .copy { $0.request.httpBody = try JSONEncoder().encode(body) }
      .setHttpHeadersForJSON()
  }

  public func body(body: Any) throws -> RequestBuilder2 {
    return try self
      .copy { $0.request.httpBody = try JSONSerialization.data(withJSONObject: body) }
      .setHttpHeadersForJSON()
  }

  // MARK: Form URL Encoded Functions
  public func form(items: [URLQueryItem]) -> RequestBuilder2 {
    return self.copy {
      $0.request.httpBody = items.compactMap { (item: URLQueryItem) -> String? in
        guard
          let value = item.value,
          let urlEncodedValue = value.addingPercentEncoding(withAllowedCharacters: RequestBuilder2.characterSet)
        else { return nil }
        return "\(item.name)=\(urlEncodedValue)"
      }
      .joined(separator: "&")
      .data(using: String.Encoding.utf8)

      $0.request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    }
  }

  // MARK: Header Function
  public func headers(headers: Set<Header>) -> RequestBuilder2 {
    return self.copy { (builder: inout RequestBuilder2) -> Void in
      headers.forEach {
        builder.request.addValue($0.value.stringValue, forHTTPHeaderField: $0.key.stringValue)
      }
    }
  }

  // MARK: Multipart Function
  public func multipart(components: [MultiPartFormDataComponent]) throws -> RequestBuilder2 {
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
  public func query(items: [URLQueryItem]) -> RequestBuilder2 {
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

public extension RequestBuilder2 {

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
