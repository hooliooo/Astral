//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

public actor OAuth2TokenStore {

  private init() {}

  public private(set) var token: OAuth2Token?

  private let fileManager: FileManager = FileManager.default

  private static let tokenName: String = "token.json"

  public func storeInMemory(token: OAuth2Token) {
    self.token = token
  }

  public func storeInFile(token: OAuth2Token) throws {
    let encoder: JSONEncoder = JSONEncoder()
    let data: Data = try encoder.encode(token)
    let url: URL = self.fileManager.ast.documentDirectory.appendingPathComponent(OAuth2TokenStore.tokenName)

    // Check if it exists first to remove the old file
    if self.fileManager.fileExists(atPath: url.path) {
      try fileManager.removeItem(at: url)
    }

    try data.write(to: url)
  }

  public var isAccessTokenExpired: Bool {
    guard let token = self.token else { return true }
    return token.isAccessTokenExpired
  }

}

public extension OAuth2TokenStore {

  static let shared: OAuth2TokenStore = .init()

}
