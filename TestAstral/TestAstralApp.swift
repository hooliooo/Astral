//
//  TestAstralApp.swift
//  TestAstral
//
//  Created by Julio Alorro on 04.02.23.
//

import SwiftUI
import class AuthenticationServices.ASWebAuthenticationSession
import class AuthenticationServices.ASPresentationAnchor
import protocol AuthenticationServices.ASWebAuthenticationPresentationContextProviding
import enum OAuth2.AuthenticationMethod
import struct OAuth2.OAuth2HTTPClient

@main
struct TestAstralApp: App {
  init() {
    let keycloakURL: String = Bundle.main.object(forInfoDictionaryKey: "KEYCLOAK_URL") as! String
    let keycloakRealm: String = Bundle.main.object(forInfoDictionaryKey: "KEYCLOAK_REALM") as! String
    let clientId: String = Bundle.main.object(forInfoDictionaryKey: "CLIENT_ID") as! String
    let clientSecret: String? = Bundle.main.object(forInfoDictionaryKey: "CLIENT_SECRET") as? String

    self.authCodeHttpClient = OAuth2HTTPClient(
      authorizationEndpoint: "\(keycloakURL)/realms/\(keycloakRealm)/protocol/openid-connect/auth",
      tokenEndpoint: "\(keycloakURL)/realms/\(keycloakRealm)/protocol/openid-connect/token",
      grantType: AuthenticationMethod.authorizationCode(
        clientId: clientId,
        clientSecret: clientSecret,
        callbackScheme: "testastral",
        redirectURI: "testastral://callback",
        delegate: AuthCodeLoginDelegate(),
        usePKCE: true
      )
    )
  }

  private let authCodeHttpClient: OAuth2HTTPClient

  var body: some Scene {
      WindowGroup {
        ContentView(service: LoginService(client: self.authCodeHttpClient))
      }
  }
}

final class AuthCodeLoginDelegate: NSObject {}

extension AuthCodeLoginDelegate: ASWebAuthenticationPresentationContextProviding {
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    return ASPresentationAnchor()
  }
}
