//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

/**
 Struct containing the data necessary to make a Resource Owner Password Credentials Grant request to an OAuth2.0 token endpoint
 */
public struct ResourceOwnerPasswordCredentialsGrant {

  /**
   Initializer for a ResourceOwnerPasswordCredentialsGrant instance
    - parameters:
        - username: Username of the user
        - password: Password of the user
        - scope: Scope of the grant
   */
  public init(username: String, password: String, scope: String? = nil) {
    self.username = username
    self.password = password
    self.scope = scope
  }

  /**
   The username to be used for authentication
   */
  public var username: String

  /**
   The password to be used for authentication
   */
  public var password: String

  /**
   The scope for authentication
   */
  public var scope: String?

}

extension ResourceOwnerPasswordCredentialsGrant: CredentialsGrant {

  public var grantType: String { "password" }

}
