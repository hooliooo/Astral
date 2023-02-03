//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//


public enum OAuthGrantRequest {
  case PKCE(redirectURI: String, scope: String?)
  case Grant(CredentialsGrant)
}
