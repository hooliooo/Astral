//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

/**
 An OAuth2Client is an entity that can request authentication of a usre
 */
public enum OAuth2Client {
  /**
   An OAuth2Client that is not required to provide a client secret when authenticating
   */
  case `public`(clientId: String)
  /**
   An OAuth2Client that is required to provide a client secret when authenticating
   */
  case confidential(credentials: ClientCredentials)
}
