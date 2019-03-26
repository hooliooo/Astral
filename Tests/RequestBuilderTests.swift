//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import XCTest
@testable import Astral

public final class RequestBuilderTests: XCTestCase {

    public func testQueryItems() {

        let builder: RequestBuilder = BaseHTTPBodyRequestBuilder(strategy: JSONStrategy())
        let urlRequest: URLRequest = builder.urlRequest(of: NestedParametersGetRequest())

        let string: String = urlRequest.url!.absoluteString.removingPercentEncoding!

        let allKeysAreIdentical: Bool = NestedParametersGetRequest().parameters.dictValue!.keys
            .allSatisfy { string.contains($0) }

        XCTAssertTrue(allKeysAreIdentical)

    }
    
}
