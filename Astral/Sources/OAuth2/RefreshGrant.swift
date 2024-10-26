//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.URLQueryItem

public struct RefreshGrant {

  /**
   The client_id
   */
  public var clientId: String

  /**
   Refresh token
   */
  public var refreshToken: String

}

extension RefreshGrant: OAuth2Grant {

  public var grantType: String { "refresh_token" }

  public var urlQueryItems: [URLQueryItem] {
    var queryItems = [
      ("client_id", \Self.clientId),
      ("grant_type", \Self.grantType),
      ("refresh_token", \Self.refreshToken)
    ]

    return queryItems.compactMap { (name: String, keyPath: PartialKeyPath<Self>) -> URLQueryItem? in
      guard let value = self[keyPath: keyPath] as? String else { return nil }
      return URLQueryItem(name: name, value: value)
    }
  }

}
