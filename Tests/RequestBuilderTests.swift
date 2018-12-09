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

        let builder: RequestBuilder = BaseHTTPBodyBuilder(strategy: JSONStrategy())
        let urlRequest: URLRequest = builder.urlRequest(of: NestedParametersGetRequest())

        let string: String = urlRequest.url!.absoluteString.removingPercentEncoding!

        var isIdentical: [Bool] = []

        NestedParametersGetRequest().parameters.dictValue!.keys.forEach {
            isIdentical.append(string.contains($0))
        }

        XCTAssertFalse(isIdentical.contains(false))

    }
    
}
