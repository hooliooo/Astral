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
    usePKCE: Bool,
    useDPoP: Bool
  )
  case clientCredentials(ClientCredentials, useDPoP: Bool)
  case password(ClientCredentials, username: String, password: String, useDPoP: Bool)

  public var name: String {
    return switch self {
      case let .authorizationCode(_, _, _, _, usePKCE, _): if usePKCE { "authorization_code_with_pkce" } else { "authorization_code" }
      case .clientCredentials: "client_credentials"
      case .password: "password"
    }
  }

  public var clientId: String {
    return switch self {
      case let .authorizationCode(client, _, _, _, _, _): client.id
      case let .clientCredentials(credentials, _), let .password(credentials, _, _, _): credentials.clientId
    }
  }

  public var useDPoP: Bool {
    return switch self {
      case let .authorizationCode(_, _, _, _, _, useDPoP):
        useDPoP
      case let .clientCredentials(_, useDPoP):
        useDPoP
      case let .password(_, _, _, useDPoP):
        useDPoP
    }
  }
}

