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
public struct AuthorizationCode {

  public init(clientId: String, scope: String? = nil, redirectURI: String) {
    self.clientId = clientId
    self.scope = scope
    self.redirectURI = redirectURI
  }

  /**
   The client id
   */
  public var clientId: String

  /**
   The response type
   */
  private let responseType: String = "code"

  /**
   The scope for authentication
   */
  public var scope: String?

  /**
   An opaque value used by the client to maintain state between the request and callback.
   The object that handles the response from the authorization server will need to read this value and
   compare it to the original one that was sent with an initial request.
   The two values must match to prevent cross-site request forgery.
   */
  private let state: String = UUID().uuidString.replacing("-", with: "")

  /**
   The redirect uri
   */
  public var redirectURI: String

  /**
   The query parameters of authorization request with PKCE verification
   */
  public var urlQueryItems: [URLQueryItem] {
    return [
      ("client_id", \Self.clientId),
      ("response_type", \Self.responseType),
      ("scope", \Self.scope),
      ("state", \Self.state),
      ("redirect_uri", \Self.redirectURI)
    ]
      .compactMap { (name: String, keyPath: PartialKeyPath<Self>) -> URLQueryItem? in
        guard let value = self[keyPath: keyPath] as? String else { return nil }
        return URLQueryItem(name: name, value: value)
      }
  }

}
