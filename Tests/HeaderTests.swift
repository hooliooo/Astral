//
//  HeaderTests.swift
//  AstralTests
//
//  Created by Julio Alorro on 2/3/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import Astral

class HeaderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testHeaderFields() {
        XCTAssertTrue(Header.Field.accept.stringValue == "Accept")
        XCTAssertTrue(Header.Field.authorization.stringValue == "Authorization")
        XCTAssertTrue(Header.Field.contentType.stringValue == "Content-Type")
        XCTAssertTrue(Header.Field.custom("MyCustomField").stringValue == "MyCustomField")
    }

    func testHeaderValues() {
        XCTAssertTrue(Header.Value.custom("MyCustomValue").stringValue == "MyCustomValue")
        XCTAssertTrue(Header.Value.basicAuthorization("myToken").stringValue == "Basic myToken")
    }

    func testMediaTypes() {
        XCTAssertTrue(MediaType.application("customFormat").stringValue == "application/customFormat")
        XCTAssertTrue(MediaType.applicationJSON.stringValue == "application/json")
        XCTAssertTrue(MediaType.applicationURLEncoded.stringValue == "application/x-www-form-urlencoded")
        XCTAssertTrue(MediaType.custom("customType", "customSubtype").stringValue == "customType/customSubtype")
        XCTAssertTrue(MediaType.multipart("customFormat").stringValue == "multipart/customFormat")

        let boundary: String = UUID().uuidString

        XCTAssertTrue(MediaType.multipartFormData(boundary).stringValue == "multipart/form-data; boundary=\(boundary)")
    }

    func testEquality() {

        let header1: Header = Header(key: Header.Field.accept, value: Header.Value.custom("Custom"))
        let header2: Header = Header(key: Header.Field.accept, value: Header.Value.mediaType(MediaType.applicationJSON))

        XCTAssertTrue(header1 == header2)

    }

    func testOverwrite() {

        let set1: Set<Header> = [Header(key: Header.Field.accept, value: Header.Value.custom("Custom"))]
        let set2: Set<Header> = [Header(key: Header.Field.accept, value: Header.Value.mediaType(MediaType.applicationJSON))]

        let combinedSet: Set<Header> = set2.union(set1)

        XCTAssertTrue(combinedSet.first!.value == Header.Value.mediaType(MediaType.applicationJSON))

    }

}