//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.JSONDecoder
import class Foundation.URLResponse
import struct Astral.HTTPClient

/**
 Contains the information taken from the /.well-known/openid-configuration endpoitn of the authorization server
 */
actor OpenIDConnectConfiguration {

  let authorizationEndpoint: String
  let tokenEndpoint: String
  let logoutEndpoint: String
  let revocationEndpoint: String
  let verifier: JWTVerifier

  init(baseURL: String, httpClient: HTTPClient) async throws {
    let decoder: JSONDecoder = JSONDecoder()
    decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
    let (payload, _): (Payload, URLResponse) = try await httpClient.get(url: "\(baseURL)/.well-known/openid-configuration").send(decoder: decoder)
    self.authorizationEndpoint = payload.authorizationEndpoint
    self.tokenEndpoint = payload.tokenEndpoint
    self.logoutEndpoint = payload.endSessionEndpoint
    self.revocationEndpoint = payload.revocationEndpoint
    self.verifier = JWTVerifier(httpClient: httpClient, url: payload.jwksUri, issuer: payload.issuer)
  }

  struct Payload: Decodable {
    let issuer: String
    let authorizationEndpoint: String
    let tokenEndpoint: String
    let jwksUri: String
    let endSessionEndpoint: String
    let revocationEndpoint: String
  }

}

