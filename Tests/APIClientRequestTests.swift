//
//  APIClientRequestTests.swift
//  
//
//  Created by Julio Alorro on 08.04.22.
//

import XCTest
@testable import Astral

class APIClientRequestTests: XCTestCase {

  public func testGetRequest() async throws {
    let (json, response): (GetResponse, URLResponse) = try await Client()
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
          Header(key: Header.Key.custom("Get-Request"), value: Header.Value.custom("Yes"))
        ]
      )
      .send()
    XCTAssertEqual("https://httpbin.org/get?this=that&what=where&why=what", response.url!.absoluteString)
    XCTAssertEqual(json.args.this, "that")
  }

  public func testPostRequest() async throws {
    let (json, response): (PostResponse, URLResponse) = try await Client()
      .post(url: "https://httpbin.org/post")
      .headers(
        headers: [
          Header(key: Header.Key.custom("Get-Request"), value: Header.Value.custom("Yes"))
        ]
      )
      .json(body: [
        "this": "that",
        "what": "where",
        "why": "what"
      ])
      .send()

    XCTAssertEqual("https://httpbin.org/post", response.url!.absoluteString)
    XCTAssertEqual(json.json.this, "that")
    XCTAssertEqual(json.json.what, "where")
    XCTAssertEqual(json.json.why, "what")
  }

  public func testMultipartRequest() async throws {
    let bundle: Bundle = Bundle.module
    let getData: (String) -> Data = { (imageName: String) -> Data in

      #if os(iOS) || os(watchOS) || os(tvOS)
      return UIImage(named: imageName, in: bundle, compatibleWith: nil)!.pngData()!
      #else
      let data = bundle.image(forResource: NSImage.Name(stringLiteral: imageName))!
        .tiffRepresentation!
      let bitmap: NSBitmapImageRep = NSBitmapImageRep(data: data)!
      return bitmap.representation(using: .png, properties: [:])!
      #endif
    }
    let getURL: (String, String) -> URL = { (imageName: String, fileExtension: String) -> URL in
      return bundle.url(forResource: imageName, withExtension: fileExtension)! // swiftlint:disable:this force_unwrapping

    }

    let (json, response): (MultipartFormDataResponse, URLResponse) = try await Client()
      .post(url: "https://httpbin.org/post")
      .headers(
        headers: [
          Header(key: Header.Key.custom("Get-Request"), value: Header.Value.custom("Yes")),
          Header(key: Header.Key.custom("Connection"), value: Header.Value.custom("Keep-Alive")),
          Header(key: Header.Key.accept, value: Header.Value.mediaType(MediaType.applicationJSON))
        ]
      )
      .multipart(
        components: [
          MultiPartFormDataComponent.text(name: "this", value: "that"),
          MultiPartFormDataComponent.text(name:"what", value: "where"),
          MultiPartFormDataComponent.text(name:"why", value: "what"),
          MultiPartFormDataComponent.image(
            name: "file1",
            fileName: "image1.png",
            contentType: "image/png",
            file: MultiPartFormDataComponent.File.data(getData("pic1"))
          ),
          MultiPartFormDataComponent.image(
            name: "file2",
            fileName: "image2.png",
            contentType: "image/png",
            file: MultiPartFormDataComponent.File.url(getURL("pic2", "png"))
          ),
          MultiPartFormDataComponent.image(
            name: "file3",
            fileName: "image3.png",
            contentType: "image/png",
            file: MultiPartFormDataComponent.File.data(getData("pic3"))
          )
        ]
      )
      .send()

    XCTAssertEqual("https://httpbin.org/post", response.url!.absoluteString)
    XCTAssertEqual(json.form.this, "that")
    XCTAssertEqual(json.form.what, "where")
    XCTAssertEqual(json.form.why, "what")
  }
}
