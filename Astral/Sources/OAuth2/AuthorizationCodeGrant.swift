//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.URLQueryItem

/**
 Struct containing the data necessary to make a Authorization Code Grant with PKCE request to an OAuth2.0 token endpoint
 */
public struct AuthorizationCodeGrant {

  /**
   Initializer for a AuthorizationCodePKCEGrant instance
    - parameters:
        - clientId: The client id
        - code: The authenication code
        - redirectURI: The redirect uri
   */
  public init(client: OAuth2Client, code: String, redirectURI: String) {
    self.client = client
    self.code = code
    self.redirectURI = redirectURI
  }

  /**
   The client id
   */
  public var client: OAuth2Client

  public var clientId: String {
    return self.client.id
  }

  /**
   The client secret
   */
  public var clientSecret: String? {
    guard case let .confidential(credentials) = self.client else { return nil}
    return credentials.clientSecret
  }

  /**
   The code given by the authorize endpoint
   */
  public var code: String

  /**
   The redirect uri
   */
  public var redirectURI: String

}

extension AuthorizationCodeGrant: OAuth2Grant {

  public var grantType: String { "authorization_code" }

  public var urlQueryItems: [URLQueryItem] {
    var queryItems = [
      ("client_id", \Self.client.id),
      ("code", \Self.code),
      ("grant_type", \Self.grantType),
      ("redirect_uri", \Self.redirectURI)
    ]
    if self.clientSecret != nil {
      queryItems.append(("client_secret", \Self.clientSecret!))
    }

    return queryItems.compactMap { (name: String, keyPath: PartialKeyPath<Self>) -> URLQueryItem? in
      guard let value = self[keyPath: keyPath] as? String else { return nil }
      return URLQueryItem(name: name, value: value)
    }
  }

}

