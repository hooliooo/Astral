//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.Date

/**
 A struct that encapsulates the token information retrieved from an OAuth2.0 token endpoint
 */
public struct OAuth2Token: Codable {

  public enum CodingKeys: String, CodingKey {
    case accessToken
    case expiresIn
    case refreshToken
    case refreshExpiresIn
    case tokenType
    case sessionState
    case scope
  }

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
  public let createdAtDate: Date = Date()

  // MARK: Computed Properties
  /**
   The date and time of the access token's expiration
   */
  public var accessTokenExpirationDate: Date {
    let seconds: Double = Double(self.expiresIn)
    return self.createdAtDate.addingTimeInterval(seconds)
  }

  /**
   Bool indicating if the access token is expired
   */
  public var isAccessTokenExpired: Bool {
    self.accessTokenExpirationDate.timeIntervalSinceNow < 0.0
  }

  /**
   The date and time of the refresh token's expiration
   */
  public var refreshTokenExpirationDate: Date {
    let seconds: Double = Double(self.refreshExpiresIn)
    return self.createdAtDate.addingTimeInterval(seconds)
  }

  /**
   Bool indicating if the refresh token is expired
   */
  public var isRefreshTokenExpired: Bool {
    self.refreshTokenExpirationDate.timeIntervalSinceNow < 0.0
  }

}
