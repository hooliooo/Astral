//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.URLResponse
import struct Astral.HTTPClient
import struct Foundation.URL
import struct JSONWebKey.JWKSet
import struct JSONWebToken.JWT
import struct os.Logger

/**
 Struct that verifies the JSON Web Token
 */
struct JWTVerifier {

  /// The HTTPClient used to communicate with the OAuth2 Server's OIDC certs endpoint
  private let httpClient: HTTPClient

  /// The URL to the OIDC certs endpoint
  private let url: URL

  /**
   The logger for the client
   */
  private static let logger: Logger = Logger(subsystem: "Astral+OAuth2", category: "JWTVerifier")

  /**
   Creates an instance of the JWTVerifier
   - parameters:
      - httpClient: The HTTPClient used to communicate with the OAuth2 Server's OIDC certs endpoint
      - url: The URL to the OIDC certs endpoint
   */
  init(httpClient: HTTPClient, url: URL) {
    self.httpClient = httpClient
    self.url = url.deletingLastPathComponent().appendingPathComponent("certs")
  }

  /**
   Verifies the token
   */
  func verify(token: OAuth2Token) async throws {
    let (jwkSet, _): (JWKSet, URLResponse) = try await self.httpClient.get(url: url.absoluteString).send()
    let jwt = try JWT(jwtString: token.accessToken)
    guard
      case let JWT.Format.jws(headerJWS) = jwt.format,
      let keyID = headerJWS.protectedHeader.keyID
    else {
      throw Error.kidNotFound
    }
    let jws = try jwkSet.key(withID: keyID)
    
    JWTVerifier.logger.debug("Verifying JWT...")
    let _: JWT = try JWT.verify(jwtString: token.accessToken, senderKey: jws)
    JWTVerifier.logger.debug("Verified JWT")
  }

  enum Error: Swift.Error {
    case kidNotFound
  }

}



