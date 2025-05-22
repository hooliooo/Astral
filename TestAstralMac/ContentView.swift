//
//  ContentView.swift
//  TestAstralMac
//
//  Created by Julio Alorro on 21.05.25.
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
      Image(systemName: "globe")
      Text("Hello World!")
    }
    .padding()
  }
}

class LoginService: NSObject {

  init(client: OAuth2HTTPClient) {
    self.client = client
  }

  private let client: OAuth2HTTPClient

  func start() {
    Task {
      try await self.client.refresh()
    }
  }

}
