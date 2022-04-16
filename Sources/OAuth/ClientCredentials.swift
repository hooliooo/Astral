//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

/**
 Struct containing the client_id and client_secret used in authenticating via OAuth2.0
 */
public struct ClientCredentials {
  /**
   The client_id
   */
  public var clientId: String

  /**
   The client_secret
   */
  public var clientSecret: String
}
