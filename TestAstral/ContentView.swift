//
//  ContentView.swift
//  TestAstral
//
//  Created by Julio Alorro on 04.02.23.
//

import Astral
import AuthenticationServices
import OAuth2
import SwiftUI

struct ContentView: View {

  let service: LoginService = .init()

  var body: some View {
    VStack {
      Button("Login") {
        self.service.start()
      }
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class LoginService: NSObject {

  let client: OAuth2HTTPClient = OAuth2HTTPClient(
    authorizationEndpoint: "http://localhost:8080/realms/master/protocol/openid-connect/auth",
    tokenEndpoint: "http://localhost:8080/realms/master/protocol/openid-connect/token",
    clientId: "some.webapp"
  )

  func start() {
    let client: OAuth2HTTPClient = self.client
    let redirectURI: String = "testastral://callback"
    let url = try! client.createAuthorizationURL(redirectURI: redirectURI)

    let session = ASWebAuthenticationSession(
      url: url,
      callbackURLScheme: "testastral"
    ) { (callbackURL: URL?, error: Error?) -> Void in
      if let callbackURL {
        Task {
          let grant: AuthorizationCodePKCEGrant = try await client
            .createAuthorizationCodeGrant(from: callbackURL, redirectURI: redirectURI)
          print("Authenticating")
          try await client.authenticate(with: grant)
        }
      }
    }

    session.presentationContextProvider = self
    session.prefersEphemeralWebBrowserSession = true
    session.start()
  }

}

extension LoginService: ASWebAuthenticationPresentationContextProviding {
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    return ASPresentationAnchor()
  }
}
