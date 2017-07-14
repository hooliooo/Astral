import UIKit
import XCTest
import BrightFutures
import Result
@testable import Astral

class Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    fileprivate func createJSON(with data: Data) -> [String: Any] {
        guard let json = try! JSONSerialization.jsonObject(with: data) as? [String: Any]
            else {
                fatalError("Could not convert to JSON")
            }

        return json
    }

    func testHeaders() {
        let expectation: XCTestExpectation = self.expectation(description: "Post Request Query")

        let requestSender: RequestSender = JSONRequestSender<JSONRequestBuilder>(request: HTTPBinGetRequest(), printsResponse: true)

        requestSender.sendURLRequest()
            .map { (response: Response) -> [String: Any] in

                return response.payload.dictValue
        
            }
            .onSuccess { (json: [String : Any]) -> Void in
                guard
                    // Headers Node
                    let headers = json[HTTPBinKeys.headers.rawValue] as? [String: String],
                    let host = headers[HTTPBinKeys.host.rawValue],
                    let contentType = headers[HTTPBinKeys.contentType.rawValue],
                    let getRequest = headers[HTTPBinKeys.getRequest.rawValue],

                    let configurationContentTypeHeader = requestSender.request.configuration.baseHeaders[HTTPBinKeys.contentType.rawValue] as? String,
                    let requestGetRequestHeader = requestSender.request.headers[HTTPBinKeys.getRequest.rawValue] as? String
                else {
                    XCTFail("Failed to get headers")
                    return
                }

                XCTAssertTrue(requestSender.request.configuration.host == host)
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

        let requestSender: RequestSender = JSONRequestSender<JSONRequestBuilder>(request: HTTPBinGetRequest(), printsResponse: true)
        requestSender.sendURLRequest()
            .map { (response: Response) -> [String: Any] in

                return response.payload.dictValue

            }
            .onSuccess { (json: [String : Any]) -> Void in
                guard
                    // Args Node
                    let args = json[HTTPBinKeys.args.rawValue] as? [String: String],
                    let thisValue = args[HTTPBinKeys.this.rawValue],
                    let requestParameterValue = requestSender.request.parameters[HTTPBinKeys.this.rawValue] as? String,

                    // URL Node
                    let url = json[HTTPBinKeys.url.rawValue] as? String
                else {
                    XCTFail("Failed to get args or url")
                    return
                }

                XCTAssertTrue(requestSender.urlRequest.url?.absoluteString == url)
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

        let requestSender: RequestSender = JSONRequestSender<JSONRequestBuilder>(request: HTTPBinPostRequest(), printsResponse: true)

        requestSender.sendURLRequest()
            .map { (response: Response) -> [String: Any] in
                return response.payload.dictValue
            }
            .onSuccess { (json: [String : Any]) -> Void in
                guard
                    // JSON Node
                    let jsonNode = json[HTTPBinKeys.json.rawValue] as? [String: String],
                    let thisValue = jsonNode[HTTPBinKeys.this.rawValue],

                    let requestThisValue = requestSender.request.parameters[HTTPBinKeys.this.rawValue] as? String

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
