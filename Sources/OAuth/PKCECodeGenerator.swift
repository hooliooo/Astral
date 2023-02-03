//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.Data
import struct Crypto.SHA256

public enum PKCEGenerator {
  /// Generate a random code as specified in
  /// https://datatracker.ietf.org/doc/html/rfc7636#section-4.1
  static func generateCodeVerifier() -> String {
    var generator = SystemRandomNumberGenerator()
    let buffer = [UInt8](repeating: 0, count: 32)
        .map { _ in UInt8.random(in: UInt8.min...UInt8.max, using: &generator) }
    return Data(buffer).base64URLEncodedString()
  }

  /// Generate a code challenge from a code verifier as specified in
  /// https://datatracker.ietf.org/doc/html/rfc7636#section-4.2
  static func generateCodeChallenge(codeVerifier: String) -> String? {
    guard let data = codeVerifier.data(using: .utf8) else { return nil }
    let dataHash = SHA256.hash(data: data)
    return Data(dataHash).base64URLEncodedString()
  }
}

private extension Data {
  func base64URLEncodedString() -> String {
    base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
      .trimmingCharacters(in: .whitespaces)
  }
}
