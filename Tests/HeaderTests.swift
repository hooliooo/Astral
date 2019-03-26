//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import XCTest
@testable import Astral

public final class HeaderTests: XCTestCase {

    public func testHeaderFields() {
        
        XCTAssertTrue(Header.Key.accept.stringValue == "Accept")
        XCTAssertTrue(Header.Key.authorization.stringValue == "Authorization")
        XCTAssertTrue(Header.Key.contentType.stringValue == "Content-Type")
        XCTAssertTrue(Header.Key.custom("MyCustomField").stringValue == "MyCustomField")
    }

    public func testHeaderValues() {
        XCTAssertTrue(Header.Value.custom("MyCustomValue").stringValue == "MyCustomValue")
        XCTAssertTrue(Header.Value.basicAuthorization("myToken").stringValue == "Basic myToken")
    }

    public func testMediaTypes() {
        XCTAssertTrue(MediaType.application("customFormat").stringValue == "application/customFormat")
        XCTAssertTrue(MediaType.applicationJSON.stringValue == "application/json")
        XCTAssertTrue(MediaType.applicationURLEncoded.stringValue == "application/x-www-form-urlencoded")
        XCTAssertTrue(MediaType.custom("customType", "customSubtype").stringValue == "customType/customSubtype")
        XCTAssertTrue(MediaType.multipart("customFormat").stringValue == "multipart/customFormat")

        let boundary: String = UUID().uuidString

        XCTAssertTrue(MediaType.multipartFormData(boundary).stringValue == "multipart/form-data; boundary=\(boundary)")
    }

    public func testEquality() {

        let header1: Header = Header(key: Header.Key.accept, value: Header.Value.custom("Custom"))
        let header2: Header = Header(key: Header.Key.accept, value: Header.Value.mediaType(MediaType.applicationJSON))

        XCTAssertTrue(header1 == header2)

    }

    public func testOverwrite() {

        let set1: Set<Header> = [Header(key: Header.Key.accept, value: Header.Value.custom("Custom"))]
        let set2: Set<Header> = [Header(key: Header.Key.accept, value: Header.Value.mediaType(MediaType.applicationJSON))]

        let combinedSet: Set<Header> = set2.union(set1)

        XCTAssertTrue(combinedSet.first!.value == Header.Value.mediaType(MediaType.applicationJSON))

    }

}
