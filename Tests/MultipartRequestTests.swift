//
//  MultipartRequestTests.swift
//  
//
//  Created by Julio Alorro on 15.04.22.
//

import XCTest
@testable import Astral

class MultipartRequestTests: XCTestCase {

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

    let (json, response): (MultipartFormDataResponse, URLResponse) = try await Constants.client
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
