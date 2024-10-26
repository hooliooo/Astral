//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

@preconcurrency import protocol AuthenticationServices.ASWebAuthenticationPresentationContextProviding

public enum AuthenticationMethod: Sendable {
  case authorizationCode(
    client: OAuth2Client,
    callbackScheme: String,
    redirectURI: String,
    delegate: ASWebAuthenticationPresentationContextProviding,
    usePKCE: Bool
  )
  case clientCredentials(ClientCredentials)
  case password(ClientCredentials, username: String, password: String)

  public var stringName: String {
    return switch self {
      case let .authorizationCode(_, _, _, _, usePKCE): if usePKCE { "authorization_code_with_pkce" } else { "authorization_code" }
      case .clientCredentials: "client_credentials"
      case .password: "password"
    }
  }

  public var clientId: String {
    return switch self {
      case let .authorizationCode(client, _, _, _, _): client.id
      case let .clientCredentials(credentials), let .password(credentials, _, _): credentials.clientId
    }
  }
}

