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

  public var stringName: String {
    return switch self {
      case let .authorizationCode(_, _, _, _, usePKCE): if usePKCE { "authorization_code_with_pkce" } else { "authorization_code" }
      case .clientCredentials: "client_credentials"
    }
  }

  public var clientId: String {
    return switch self {
      case let .authorizationCode(client, _, _, _, _): client.id
      case let .clientCredentials(credentials): credentials.clientId
    }
  }
}

