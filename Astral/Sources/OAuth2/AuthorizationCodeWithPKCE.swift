//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.URLQueryItem
import struct Foundation.UUID

/**
 Struct containing the data necessary to make an Authorization request with PKCE verification to an OAuth2.0 authorization endpoint
 */
public struct AuthorizationCodeWithPKCE {

  public init(clientId: String, scope: String? = nil, codeChallenge: String, redirectURI: String) {
    self.authorizationCode = AuthorizationCode(clientId: clientId, scope: scope, redirectURI: redirectURI)
    self.codeChallenge = codeChallenge
  }

  private let authorizationCode: AuthorizationCode

  /**
   The client id
   */
  public var clientId: String {
    self.authorizationCode.clientId
  }

  /**
   The scope for authentication
   */
  public var scope: String? {
    self.authorizationCode.scope
  }

  /**
   The code challenge given to the authorize endpoint
   */
  public var codeChallenge: String

  /**
   The code challenge given to the authorize endpoint
   */
  private let codeChallengeMethod: String = "S256"

  /**
   The redirect uri
   */
  public var redirectURI: String {
    self.authorizationCode.redirectURI
  }

  /**
   The query parameters of authorization request with PKCE verification
   */
  public var urlQueryItems: [URLQueryItem] {
    let queryItems: [URLQueryItem] = [
      ("code_challenge", \Self.codeChallenge),
      ("code_challenge_method", \Self.codeChallengeMethod),
    ]
      .compactMap { (name: String, keyPath: PartialKeyPath<Self>) -> URLQueryItem? in
        guard let value = self[keyPath: keyPath] as? String else { return nil }
        return URLQueryItem(name: name, value: value)
      }
    return queryItems + authorizationCode.urlQueryItems
  }

}
