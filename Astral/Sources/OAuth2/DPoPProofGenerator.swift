//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.JSONEncoder
import enum CryptoKit.P256
import struct CryptoKit.SHA256
import struct Foundation.Data
import struct Foundation.Date
import struct Foundation.URLComponents
import struct Foundation.UUID

public enum DPoPProofGenerator {

  private static let encoder: JSONEncoder = JSONEncoder()

  public static func generate(privateKey: P256.Signing.PrivateKey, parameters: Parameters) throws -> String {
    let header = try buildHeader(publicKey: privateKey.publicKey)
    let payload = try buildPayload(parameters: parameters)

    let headerB64 = base64URLEncode(header)
    let payloadB64 = base64URLEncode(payload)
    let input = "\(headerB64).\(payloadB64)"

    guard let data = input.data(using: String.Encoding.ascii) else {
      throw Error.encodingFailed
    }

    let signature = try privateKey.signature(for: data)
    let signatureB64 = base64URLEncode(signature.rawRepresentation)

    return "\(input).\(signatureB64)"

  }

  public static func generateJWKThumbprint(_ publicKey: P256.Signing.PublicKey) throws -> String {
    let jwk = publicKeyToJWK(publicKey)
    // RFC 7638: members in lexicographic order, no whitespace
    let dataString = #"{"crv":"\#(jwk.crv)","kty":"\#(jwk.kty)","x":"\#(jwk.x)","y":"\#(jwk.y)"}"#
    let data = Data(dataString.utf8)
    let hash = SHA256.hash(data: data)
    return base64URLEncode(Data(hash))
  }

  private static func publicKeyToJWK(_ publicKey: P256.Signing.PublicKey) -> JWK {
    let rawKey: Data = publicKey.x963Representation
    let x: Data = rawKey[1..<33]
    let y: Data = rawKey[33..<65]
    return JWK(
      crv: "P-256",
      kty: "EC",
      x: base64URLEncode(x),
      y: base64URLEncode(y)
    )
  }

  private static func buildHeader(publicKey: P256.Signing.PublicKey) throws -> Data {
    let jwk: JWK = publicKeyToJWK(publicKey)
    let header: Header = Header(
      typ: "dpop+jwt",
      alg: "ES256",
      jwk: jwk
    )
    return try encoder.encode(header)
  }

  private static func buildPayload(parameters: Parameters) throws -> Data {
    let htu: String = {
      guard var components = URLComponents(string: parameters.url) else { return parameters.url }
      components.query = nil
      components.fragment = nil
      return components.string!
    }()

    let ath: String? = {
      guard let token = parameters.accessToken else { return nil }
      let data = Data(token.utf8)
      let hash = SHA256.hash(data: data)
      return base64URLEncode(Data(hash))
    }()

    let payload = Payload(
      jti: UUID(),
      htm: parameters.httpMethod,
      htu: htu,
      ath: ath,
      nonce: parameters.nonce
    )

    return try encoder.encode(payload)
  }

  // MARK: - Base64URL
  private static func base64URLEncode(_ data: Data) -> String {
    data.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }

  struct Header: Encodable {
    let typ: String
    let alg: String
    let jwk: JWK
  }

  struct JWK: Encodable {
    let crv: String
    let kty: String
    let x: String
    let y: String
  }

  public struct Parameters {
    let httpMethod: String          // e.g. "POST", "GET"
    let url: String                 // e.g. "https://keycloak.example.com/realms/myrealm/protocol/openid-connect/token"
    let accessToken: String?        // nil for token requests; set for resource server calls
    let nonce: String?              // server-provided nonce (if Keycloak returns one)
  }

  struct Payload: Encodable {
    let jti: UUID
    let iat: Int = Int(Date().timeIntervalSince1970)
    let htm: String
    let htu: String
    let ath: String?
    let nonce: String?
  }

  enum Error: Swift.Error {
    case encodingFailed
  }
}
