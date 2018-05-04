import XCTest
@testable import Astral

public final class RequestBuilderTests: XCTestCase {

    public override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    public override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    public func testQueryItems() {

        let builder: RequestBuilder = BaseRequestBuilder(strategy: JSONStrategy())
        let urlRequest: URLRequest = builder.urlRequest(of: NestedParametersGetRequest())

        let isIdentical: Bool = "https://httpbin.org/get?nestedArray=this&nestedArray=that&nestedArray=what&nested={\"aDict\":\"someValue\"}&anotherNested={\"anotherDict\":3}" == urlRequest.url!.absoluteString.removingPercentEncoding!

        XCTAssertTrue(isIdentical)

    }
    
}
