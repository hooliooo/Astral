//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 A struct that encapsulates the token information retrieved from an OAuth2.0 token endpoint
 */
public struct OAuth2Token: Decodable {

  /**
   The access token
   */
  public var accessToken: String

  /**
   The duration (in seconds) of validity of the access token
   */
  public var expiresIn: Int

  /**
   The refresh token
   */
  public var refreshToken: String

  /**
   The duration (in seconds) of the validity of the refresh token
   */
  public var refreshExpiresIn: Int

  /**
   The token type
   */
  public var tokenType: String

  /**
   The session state
   */
  public var sessionState: String

  /**
   The scope of token
   */
  public var scope: String

  /**
   The date and time of the token's creation
   */
  public private(set)var createdAtDate: Date = Date()

}
