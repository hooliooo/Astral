//
//  ContentView.swift
//  TestAstral
//
//  Created by Julio Alorro on 04.02.23.
//

import Astral
import AuthenticationServices
import OAuth
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

  let client: OAuth2Client = OAuth2Client(
    authorizationEndpoint: "http://localhost:8080/realms/master/protocol/openid-connect/auth",
    tokenEndpoint: "http://localhost:8080/realms/master/protocol/openid-connect/token",
    clientId: "some.webapp"
  )

  func start() {
    let codeVerifier = PKCEGenerator.generateCodeVerifier()
    let codeChallenge = PKCEGenerator.generateCodeChallenge(codeVerifier: codeVerifier)!

    let authorization = PKCEAuthorization(
      clientId: "some.webapp",
      codeChallenge: codeChallenge,
      redirectURI: "testastral:/"
    )

    var components = try! self.client.authorize(authorization: authorization).urlComponents
    components.queryItems = authorization.urlQueryItems

    let session = ASWebAuthenticationSession(
      url: components.url!,
      callbackURLScheme: "testastral"
    ) { (callbackURL: URL?, error: Error?) -> Void in
      print(callbackURL)
      print(error)
    }

    session.presentationContextProvider = self
    session.start()
  }

}

extension LoginService: ASWebAuthenticationPresentationContextProviding {
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    return ASPresentationAnchor()
  }
}
