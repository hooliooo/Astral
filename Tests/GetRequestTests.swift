//
//  APIClientRequestTests.swift
//  
//
//  Created by Julio Alorro on 08.04.22.
//

import XCTest
@testable import Astral

class GetRequestTests: XCTestCase {

  public func testGetRequest() async throws {
    let (json, response): (GetResponse, URLResponse) = try await Constants.client
      .get(url: "https://httpbin.org/get")
      .query(
        items: [
          URLQueryItem(name: "this", value: "that"),
          URLQueryItem(name: "what", value: "where"),
          URLQueryItem(name: "why", value: "what")
        ]
      )
      .headers(
        headers: [
          Header(key: Header.Key.custom("Get-Request"), value: Header.Value.custom("Yes")),
          Header(key: Header.Key.accept, value: Header.Value.mediaType(.applicationJSON)),
          Header(key: Header.Key.contentType, value: Header.Value.mediaType(.applicationJSON))
        ]
      )
      .send()
    dump(json)
    XCTAssertEqual("https://httpbin.org/get?this=that&what=where&why=what", response.url!.absoluteString)
    XCTAssertEqual(json.args.this, "that")
  }
}
