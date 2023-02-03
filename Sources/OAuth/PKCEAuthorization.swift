//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.URLQueryItem
import struct Foundation.UUID

public struct PKCEAuthorization {

  public init(clientId: String, scope: String? = nil, codeChallenge: String, redirectURI: String) {
    self.clientId = clientId
    self.scope = scope
    self.codeChallenge = codeChallenge
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

  private let state: String = UUID().uuidString.replacing("-", with: "")

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
  public var redirectURI: String

  /**

   */
  public var urlQueryItems: [URLQueryItem] {
    return [
      ("client_id", \Self.clientId),
      ("response_type", \Self.responseType),
      ("scope", \Self.scope),
      ("state", \Self.state),
      ("code_challenge", \Self.codeChallenge),
      ("code_challenge_method", \Self.codeChallengeMethod),
      ("redirect_uri", \Self.redirectURI)
    ]
      .compactMap { (name: String, keyPath: PartialKeyPath<Self>) -> URLQueryItem? in
        guard let value = self[keyPath: keyPath] as? String else { return nil }
        return URLQueryItem(name: name, value: value)
      }
  }

}
