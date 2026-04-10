//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.JSONDecoder
import class Foundation.JSONEncoder
import class Foundation.FileManager
import struct Foundation.Data
import struct Foundation.URL

public actor OAuth2TokenStore: Sendable {

  public init(method: AuthenticationMethod) {
    self.tokenName = "\(method.name)-token.json"
  }

  public private(set) var token: OAuth2Token?

  public private(set) var codeVerifier: String?

  public private(set) var state: String?

  private let fileManager: FileManager = FileManager.default

  private let tokenName: String

  public var isAccessTokenExpired: Bool {
    guard let token = self.token else { return true }
    return token.isAccessTokenExpired
  }

  public var isRefreshTokenExpired: Bool {
    guard let token = self.token else { return true }
    return token.isRefreshTokenExpired
  }

  public var hasToken: Bool {
    self.token != nil
  }

  public func storeInMemory(token: OAuth2Token) {
    self.token = token
  }

  public func storeInFile(token: OAuth2Token) throws {
    let encoder: JSONEncoder = JSONEncoder()
    let data: Data = try encoder.encode(token)
    let url: URL = self.fileManager.ast.documentDirectory.appendingPathComponent(self.tokenName)

    // Check if it exists first to remove the old file
    if self.fileManager.fileExists(atPath: url.path) {
      try self.fileManager.removeItem(at: url)
    }

    try data.write(to: url)
  }

  public func store(token: OAuth2Token) throws {
    self.storeInMemory(token: token)
    try self.storeInFile(token: token)
  }

  public func store(codeVerifier: String) {
    self.codeVerifier = codeVerifier
  }

  public func store(state: String) {
    self.state = state
  }

  public func clear() {
    self.state = nil
    self.codeVerifier = nil
  }

  public func readFromFile() throws -> OAuth2Token? {
    let url: URL = self.fileManager.ast.documentDirectory.appendingPathComponent(self.tokenName)
    // Check if it exists first to remove the old file
    guard self.fileManager.fileExists(atPath: url.path)
    else { return nil }

    let data: Data = try Data(contentsOf: url)
    let decoder: JSONDecoder = JSONDecoder()
    let token: OAuth2Token = try decoder.decode(OAuth2Token.self, from: data)
    self.storeInMemory(token: token)
    return token
  }

  public func removeToken() throws {
    let url: URL = self.fileManager.ast.documentDirectory.appendingPathComponent(self.tokenName)
    if self.fileManager.fileExists(atPath: url.path) {
      try self.fileManager.removeItem(at: url)
    }
    self.token = nil
  }

}
