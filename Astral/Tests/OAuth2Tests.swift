//
//  File.swift
//  
//
//  Created by Julio Alorro on 14.04.22.
//

import Foundation
import XCTest
@testable import Astral
@testable import OAuth2

public class OAuth2Tests: XCTestCase {

  public func testPasswordCredentialsOAuth2() async throws {
//    let builder = try await Constants.client2
//      .authenticate(
//        url: "http://localhost:8080/realms/master/protocol/openid-connect/token",
//        credentialsGrant: ResourceOwnerPasswordCredentialsGrant(
//          username: "testuser1",
//          password: "test1234",
//          scope: nil,
//          credentials: ClientCredentials(
//            clientId: "some.webapp",
//            clientSecret: "H8UXgIW8FcbZeB2VvQbKDDdwu2rsZqEr"
//          )
//        )
//      )
//    XCTFail()
//    let decoder: JSONDecoder = JSONDecoder()
//    decoder.keyDecodingStrategy = .convertFromSnakeCase
//    let (token, response): (OAuth2Token, URLResponse) = try await builder.send(decoder: decoder)
//    let httpResponse = response as! HTTPURLResponse

//    XCTAssertEqual("https://httpbin.org/post?maxResults=100&page=0", httpResponse.url!.absoluteString)
//    XCTAssertEqual(json.json.username, "Testing Tester")
//    XCTAssertEqual(json.json.password, "aWeakPassword")
  }

}
