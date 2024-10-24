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
    self.authorizationCodeGrant = AuthorizationCodeGrant(clientId: clientId, code: code, redirectURI: redirectURI)
    self.codeVerifier = codeVerifier
  }

  private let authorizationCodeGrant: AuthorizationCodeGrant

  /**
   The client id
   */
  public var clientId: String {
    self.authorizationCodeGrant.clientId
  }

  /**
   The code given by the authorize endpoint
   */
  public var code: String {
    self.authorizationCodeGrant.code
  }

  /**
   The code verifier used to verify the code challenge
   */
  public var codeVerifier: String

  /**
   The redirect uri
   */
  public var redirectURI: String {
    self.authorizationCodeGrant.redirectURI
  }

}

extension AuthorizationCodePKCEGrant: OAuth2Grant {

  public var grantType: String { self.authorizationCodeGrant.grantType }

  public var urlQueryItems: [URLQueryItem] {
    let queryItems = [
      ("code_verifier", \Self.codeVerifier)
    ]
      .compactMap { (name: String, keyPath: PartialKeyPath<Self>) -> URLQueryItem? in
        guard let value = self[keyPath: keyPath] as? String else { return nil }
        return URLQueryItem(name: name, value: value)
      }
    return queryItems + self.authorizationCodeGrant.urlQueryItems
  }

}
