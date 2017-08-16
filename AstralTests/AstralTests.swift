import UIKit
import XCTest
import BrightFutures
import Result
@testable import Astral

class AstralTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testHeaders() {
        let expectation: XCTestExpectation = self.expectation(description: "Post Request Query")

        let requestDispatcher: RequestDispatcher = JSONRequestDispatcher(
            request: HTTPBinGetRequest(),
            builderType: JSONRequestBuilder.self,
            strategy: JSONStrategy()
        )

        requestDispatcher.dispatchURLRequest()
            .map { (response: Response) -> [String: Any] in
                print(response)
                return response.json.dictValue

            }
            .onSuccess { (json: [String : Any]) -> Void in
                let configuration = requestDispatcher.request.configuration
                guard
                    // Headers Node
                    let headers = json[HTTPBinKeys.headers.rawValue] as? [String: String],
                    let host = headers[HTTPBinKeys.host.rawValue],
                    let contentType = headers[HTTPBinKeys.contentType.rawValue],
                    let getRequest = headers[HTTPBinKeys.getRequest.rawValue],

                    let configurationContentTypeHeader = configuration.baseHeaders[HTTPBinKeys.contentType.rawValue] as? String,
                    let requestGetRequestHeader = requestDispatcher.request.headers[HTTPBinKeys.getRequest.rawValue] as? String
                else {
                    XCTFail("Failed to get headers")
                    return
                }

                XCTAssertTrue(requestDispatcher.request.configuration.host == host)
                XCTAssertTrue(configurationContentTypeHeader == contentType)
                XCTAssertTrue(requestGetRequestHeader == getRequest)
                expectation.fulfill()

            }
            .onFailure { (error: NetworkingError) -> Void in
                XCTFail(error.localizedDescription)
        }

        self.waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testGetRequest() {

        let expectation: XCTestExpectation = self.expectation(description: "Get Request Query")

        let requestDispatcher: RequestDispatcher = JSONRequestDispatcher(
            request: HTTPBinGetRequest(),
            builderType: JSONRequestBuilder.self,
            strategy: JSONStrategy()
        )
        requestDispatcher.dispatchURLRequest()
            .map { (response: Response) -> [String: Any] in

                return response.json.dictValue

            }
            .onSuccess { (json: [String : Any]) -> Void in
                guard
                    // Args Node
                    let args = json[HTTPBinKeys.args.rawValue] as? [String: String],
                    let thisValue = args[HTTPBinKeys.this.rawValue],
                    let requestParameterValue = requestDispatcher.request.parameters[HTTPBinKeys.this.rawValue] as? String,

                    // URL Node
                    let url = json[HTTPBinKeys.url.rawValue] as? String
                else {
                    XCTFail("Failed to get args or url")
                    return
                }

                XCTAssertTrue(requestDispatcher.urlRequest.url?.absoluteString == url)
                XCTAssertTrue(requestParameterValue == thisValue)
                expectation.fulfill()

            }
            .onFailure { (error: NetworkingError) -> Void in

                XCTFail(error.localizedDescription)

        }

        self.waitForExpectations(timeout: 5.0, handler: nil)

    }

    /**
     PUT and DELETE http methods produce identical results with POST request
    */
    func testPostRequest() {
        let expectation: XCTestExpectation = self.expectation(description: "Post Request Query")

        let requestDispatcher: RequestDispatcher = JSONRequestDispatcher(
            request: HTTPBinPostRequest(),
            builderType: JSONRequestBuilder.self,
            strategy: FormURLEncodedStrategy()
        )

        requestDispatcher.dispatchURLRequest()
            .map { (response: Response) -> [String: Any] in
                return response.json.dictValue
            }
            .onSuccess { (json: [String : Any]) -> Void in
                guard
                    // JSON Node
                    let formNode = json[HTTPBinKeys.form.rawValue] as? [String: String],
                    let thisValue = formNode[HTTPBinKeys.this.rawValue],

                    let requestThisValue = requestDispatcher.request.parameters[HTTPBinKeys.this.rawValue] as? String

                else {
                    XCTFail("Failed to get json")
                    return
                }

                XCTAssertTrue(requestThisValue == thisValue)
                expectation.fulfill()
            }
            .onFailure { (error: NetworkingError) -> Void in
                XCTFail(error.localizedDescription)
            }

        self.waitForExpectations(timeout: 5.0, handler: nil)
    }

}
