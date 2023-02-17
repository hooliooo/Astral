//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.URLQueryItem

/**
 Struct containing the data necessary to make a Resource Owner Password Credentials Grant request to an OAuth2.0 token endpoint
 */
public struct ResourceOwnerPasswordCredentialsGrant {

  /**
   Initializer for a ResourceOwnerPasswordCredentialsGrant instance
    - parameters:
        - username: Username of the user
        - password: Password of the user
        - scope: Scope of the grant
   */
  public init(username: String, password: String, scope: String? = nil, credentials: ClientCredentials) {
    self.username = username
    self.password = password
    self.scope = scope
    self.credentials = credentials
  }

  /**
   The username to be used for authentication
   */
  public var username: String

  /**
   The password to be used for authentication
   */
  public var password: String

  /**
   The scope for authentication
   */
  public var scope: String?

  /**
   The client credentials for authentications
   */
  public var credentials: ClientCredentials

}

extension ResourceOwnerPasswordCredentialsGrant: OAuth2Grant {

  public var grantType: String { "password" }

  public var urlQueryItems: [URLQueryItem] {
    return [
      ("password", \Self.password),
      ("username", \Self.username),
      ("grant_type", \Self.grantType),
      ("scope", \Self.scope),
      ("client_id", \Self.credentials.clientId),
      ("client_secret", \Self.credentials.clientSecret)
    ]
      .compactMap { (name: String, keyPath: PartialKeyPath<Self>) -> URLQueryItem? in
        guard let value = self[keyPath: keyPath] as? String else { return nil }
        return URLQueryItem(name: name, value: value)
      }
  }

}
