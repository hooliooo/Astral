//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.URLQueryItem

/**
 Struct containing the data necessary to make a Client Credentials Grant request to an OAuth2.0 token endpoint
 */
public struct ClientCredentialsGrant {

  /**
   Initializer for a ClientCredentialsGrant instance
    - parameters:
        - credentials: The credentials of the client
        - scope: Scope of the grant
   */
  public init(credentials: ClientCredentials, scope: String? = nil) {
    self.credentials = credentials
    self.scope = scope
  }

  /**
   The client credentials to be used for authentication
   */
  public var credentials: ClientCredentials

  /**
   The scope for authentication
   */
  public var scope: String?

}

extension ClientCredentialsGrant: CredentialsGrant {

  public var grantType: String { "client_credentials" }

  public var urlQueryItems: [URLQueryItem] {
    return [
      ("client_id", \Self.credentials.clientId),
      ("client_secret", \Self.credentials.clientSecret),
      ("grant_type", \Self.grantType),
      ("scope", \Self.scope)
    ]
      .compactMap { (name: String, keyPath: PartialKeyPath<Self>) -> URLQueryItem? in
        guard let value = self[keyPath: keyPath] as? String else { return nil }
        return URLQueryItem(name: name, value: value)
      }
  }

}
