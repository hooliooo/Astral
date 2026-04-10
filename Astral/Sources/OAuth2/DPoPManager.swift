//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import enum CryptoKit.P256
import struct Foundation.Data
import Security

public struct DPoPManager {

  public init(appName: String) {
    self.keychainTag = "\(appName).dpop.key"
  }

  private let keychainTag: String

  public func generateAndStoreKey() throws -> P256.Signing.PrivateKey {
    let privateKey = P256.Signing.PrivateKey()
    let query: [String: Any] = [
      kSecClass as String:              kSecClassGenericPassword,
      kSecAttrAccount as String:        keychainTag,
      kSecValueData as String:          privateKey.rawRepresentation,
      kSecAttrAccessible as String:     kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    ]

    // Remove any existing key first
    SecItemDelete(query as CFDictionary)

    let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
      throw Error.keychainWriteFailed(status)
    }
    return privateKey

  }

  /// Retrieve the stored private key, or generate a new one if none exists.
  public func retrieveOrCreateKey() throws -> P256.Signing.PrivateKey {
    let query: [String: Any] = [
      kSecClass as String:         kSecClassGenericPassword,
      kSecAttrAccount as String:   keychainTag,
      kSecReturnData as String:    true
    ]

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)

    if status == errSecSuccess, let data = result as? Data {
      return try P256.Signing.PrivateKey(rawRepresentation: data)
    }

    return try generateAndStoreKey()
  }

  enum Error: Swift.Error {
    case keychainWriteFailed(OSStatus)
  }

}
