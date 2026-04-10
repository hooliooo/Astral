//
//  ContentView.swift
//  TestAstral
//
//  Created by Julio Alorro on 04.02.23.
//

import Astral
import class AuthenticationServices.ASWebAuthenticationSession
import class AuthenticationServices.ASPresentationAnchor
import protocol AuthenticationServices.ASWebAuthenticationPresentationContextProviding
import OAuth2
import SwiftUI

struct ContentView: View {

  let service: LoginService

  var body: some View {
    VStack(spacing: 10) {
      Button("Login Regular") {
        self.service.login()
      }
      Button("Login Offline") {
        self.service.login(scope: "openid profile email offline_access")
      }
      Link("Account", destination: URL(string: "http://localhost:8080/realms/oneqrew/account")!)
      Button("Logout") {
        self.service.logout()
      }
    }
    .padding()
  }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//      ContentView(service: LoginService(keycloakURL: "", clientId: "", clientSecret: nil))
//    }
//}

class LoginService: NSObject {

  init(client: OAuth2HTTPClient) {
    self.client = client
  }

  private let client: OAuth2HTTPClient

  func login(scope: String = "openid profile email") {
    Task { try await self.client.refresh(scope: scope) }
  }

  func logout() {
    Task { try await self.client.logout() }
  }

}
