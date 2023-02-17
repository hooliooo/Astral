//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.URLQueryItem

/**
 Struct containing the data necessary to make a Authorization Code Grant with PKCE request to an OAuth2.0 token endpoint
 */
public struct AuthorizationCodePKCEGrant {

  /**
   Initializer for a AuthorizationCodePKCEGrant instance
    - parameters:
        - clientId: The client id
        - code: The authenication code
        - codeVerifier: The code verifier for the PKCE verificiation
        - redirectURI: The redirect uri
   */
  public init(clientId: String, code: String, codeVerifier: String, redirectURI: String) {
    self.clientId = clientId
    self.code = code
    self.codeVerifier = codeVerifier
    self.redirectURI = redirectURI
  }

  /**
   The client id
   */
  public var clientId: String

  /**
   The code given by the authorize endpoint
   */
  public var code: String

  /**
   The code verifier used to verify the code challenge
   */
  public var codeVerifier: String

  /**
   The redirect uri
   */
  public var redirectURI: String

}

extension AuthorizationCodePKCEGrant: OAuth2Grant {

  public var grantType: String { "authorization_code" }

  public var urlQueryItems: [URLQueryItem] {
    return [
      ("client_id", \Self.clientId),
      ("code", \Self.code),
      ("grant_type", \Self.grantType),
      ("code_verifier", \Self.codeVerifier),
      ("redirect_uri", \Self.redirectURI)
    ]
      .compactMap { (name: String, keyPath: PartialKeyPath<Self>) -> URLQueryItem? in
        guard let value = self[keyPath: keyPath] as? String else { return nil }
        return URLQueryItem(name: name, value: value)
      }
  }

}
