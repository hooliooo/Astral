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
    VStack {
      Button("Login") {
        self.service.start()
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

  func start() {
    Task { try await self.client.refresh() }
  }

}
