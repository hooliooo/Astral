//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.Data
import struct Foundation.URLQueryItem
import struct Foundation.UUID
import enum Crypto.ChaChaPoly

/**
 Struct containing the data necessary to make an Implicit Authorization request to an OAuth2.0 authorization endpoint
 */
public struct ImplicitGrant {

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
  private let responseType: String = "id_token token"

  /**
   The response mode
   */
  private let responseMode: String = "form_post"

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
   A cryptographically random string used to prevent token replay attacks
   */
  private let nonce: String = Data(ChaChaPoly.Nonce.init()).base64EncodedString()

  /**
   The redirect uri
   */
  public var redirectURI: String

  /**

   */
  public var urlQueryItems: [URLQueryItem] {
    return [
      ("client_id", \Self.clientId),
      ("response_type", \Self.responseType),
      ("response_mode", \Self.responseMode),
      ("scope", \Self.scope),
      ("state", \Self.state),
      ("nonce", \Self.nonce),
      ("redirect_uri", \Self.redirectURI)
    ]
      .compactMap { (name: String, keyPath: PartialKeyPath<Self>) -> URLQueryItem? in
        guard let value = self[keyPath: keyPath] as? String else { return nil }
        return URLQueryItem(name: name, value: value)
      }
  }

}