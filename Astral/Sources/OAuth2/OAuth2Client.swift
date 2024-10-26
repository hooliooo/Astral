//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

/**
 An OAuth2Client is an entity that can request authentication of a usre
 */
public enum OAuth2Client: Sendable {
  /**
   An OAuth2Client that is not required to provide a client secret when authenticating
   */
  case `public`(clientId: String)
  /**
   An OAuth2Client that is required to provide a client secret when authenticating
   */
  case confidential(credentials: ClientCredentials)

  public var id: String {
    return switch self {
      case let .`public`(clientId): clientId
      case let .confidential(credentials): credentials.clientId
    }
  }
}

// MARK: Hashable Protocol
extension OAuth2Client: Hashable {

  public static func == (lhs: OAuth2Client, rhs: OAuth2Client) -> Bool {
    switch (lhs, rhs) {
      case let (.`public`(lhsClientId), .`public`(rhsClientId)): return lhsClientId == rhsClientId
      case let (.confidential(lhsCredentials), .confidential(rhsCredentials)): return lhsCredentials == rhsCredentials
      default: return false
    }
  }

  public func hash(into hasher: inout Hasher) {
    switch self {
      case let .`public`(clientId): hasher.combine(clientId)
      case let .confidential(credentials): hasher.combine(credentials)
    }
  }

}
