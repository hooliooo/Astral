//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

public actor OAuth2TokenStore {

  private init() {}

  public private(set) var token: OAuth2Token?

  public func store(token: OAuth2Token) {
    self.token = token
  }

  public var isAccessTokenExpired: Bool {
    guard let token = self.token else { return true }
    return token.isAccessTokenExpired
  }

}

public extension OAuth2TokenStore {

  static let shared: OAuth2TokenStore = .init()

}
