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
import enum OAuth2.OAuth2Client
import class OAuth2.OAuth2HTTPClient

@main
struct TestAstralApp: App {
  init() {
    let keycloakURL: String = Bundle.main.object(forInfoDictionaryKey: "KEYCLOAK_URL") as! String
    let keycloakRealm: String = Bundle.main.object(forInfoDictionaryKey: "KEYCLOAK_REALM") as! String
    let clientId: String = Bundle.main.object(forInfoDictionaryKey: "CLIENT_ID") as! String
    let clientSecret: String? = Bundle.main.object(forInfoDictionaryKey: "CLIENT_SECRET") as? String
    let callbackScheme: String = Bundle.main.object(forInfoDictionaryKey: "CALLBACK_SCHEME") as! String
    let redirectURI: String = Bundle.main.object(forInfoDictionaryKey: "REDIRECT_URI") as! String

    self.authCodeHttpClient = OAuth2HTTPClient(
      baseURL: "\(keycloakURL)/realms/\(keycloakRealm)",
//      authorizationEndpoint: "\(keycloakURL)/realms/\(keycloakRealm)/protocol/openid-connect/auth",
//      tokenEndpoint: "\(keycloakURL)/realms/\(keycloakRealm)/protocol/openid-connect/token",
      method: AuthenticationMethod.authorizationCode(
        client: OAuth2Client.public(clientId: clientId),
        callbackScheme: callbackScheme,
        redirectURI: redirectURI,
        delegate: AuthCodeLoginDelegate(),
        usePKCE: true,
        useDPoP: true
      ),
      appName: Bundle.main.bundleIdentifier!
    )

//    self.clientCredentialsHttpClient = OAuth2HTTPClient(
//      authorizationEndpoint: "\(keycloakURL)/realms/\(keycloakRealm)/protocol/openid-connect/auth",
//      tokenEndpoint: "\(keycloakURL)/realms/\(keycloakRealm)/protocol/openid-connect/token",
//      grantType: AuthenticationMethod.clientCredentials(clientId: clientId, clientSecret: clientSecret)
//    )
  }

  private let authCodeHttpClient: OAuth2HTTPClient
//  private let clientCredentialsHttpClient: OAuth2HTTPClient

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
