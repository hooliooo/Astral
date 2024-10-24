//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import XCTest
@testable import Astral
@testable import OAuth2

class PostRequestTests: XCTestCase {

  public func testJSONPostRequest() async throws {
    let body: User = User(username: "Testing Tester", password: "aWeakPassword")
    let builder = try Constants.client
      .post(url: "https://httpbin.org/post")
      .headers(
        headers: [
          Header(key: Header.Key.custom("Get-Request"), value: Header.Value.custom("Yes"))
        ]
      )
      .json(body: body)
    XCTAssertEqual(builder.request.httpMethod!, HTTPMethod.post.stringValue)
    let mediaType = builder.request.allHTTPHeaderFields?[Header.Key.contentType.stringValue]!
    XCTAssertEqual(MediaType.applicationJSON.stringValue, mediaType)

    let (json, response): (PostResponse, URLResponse) = try await builder.send()

    let httpResponse = response as! HTTPURLResponse
    let headers = httpResponse.allHeaderFields
    let contentLengthResp = (headers["Content-Length"] as? String).flatMap(Int.init)!
    XCTAssertEqual("https://httpbin.org/post", httpResponse.url!.absoluteString)
    XCTAssertTrue(contentLengthResp > 0)
    XCTAssertEqual(json.json.username, "Testing Tester")
    XCTAssertEqual(json.json.password, "aWeakPassword")
  }

  public func testJSONPostRequestWithQuery() async throws {
    let body: User = User(username: "Testing Tester", password: "aWeakPassword")
    let builder = try Constants.client
      .post(url: "https://httpbin.org/post")
      .headers(
        headers: [
          Header(key: Header.Key.custom("Get-Request"), value: Header.Value.custom("Yes"))
        ]
      )
      .query(
        items: [
          URLQueryItem(name: "maxResults", value: 100.description),
          URLQueryItem(name: "page", value: 0.description)
        ]
      )
      .json(body: body)

    let (json, response): (PostResponse, URLResponse) = try await builder.send()
    let httpResponse = response as! HTTPURLResponse

    XCTAssertEqual("https://httpbin.org/post?maxResults=100&page=0", httpResponse.url!.absoluteString)
    XCTAssertEqual(json.json.username, "Testing Tester")
    XCTAssertEqual(json.json.password, "aWeakPassword")
  }
  
}
