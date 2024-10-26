//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

@preconcurrency import protocol AuthenticationServices.ASWebAuthenticationPresentationContextProviding

public enum AuthenticationMethod: Sendable {
  case authorizationCode(
    clientId: String,
    clientSecret: String?,
    callbackScheme: String,
    redirectURI: String,
    delegate: ASWebAuthenticationPresentationContextProviding,
    usePKCE: Bool
  )
  case clientCredentials(clientId: String, clientSecret: String)

  public var stringName: String {
    return switch self {
      case let .authorizationCode(_, _, _, _, _, usePKCE): if usePKCE { "authorization_code_with_pkce" } else { "authorization_code" }
      case .clientCredentials: "client_credentials"
    }
  }

  public var clientId: String {
    return switch self {
      case let .authorizationCode(clientId, _, _, _, _, _): clientId
      case let .clientCredentials(clientId, _): clientId
    }
  }
}

