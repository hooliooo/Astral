import UIKit
import XCTest
import BrightFutures
import Result
@testable import Astral

// swiftlint:disable force_cast
class Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    let decoder: JSONDecoder = JSONDecoder()

//    func testHeaders() {
//        let expectation: XCTestExpectation = self.expectation(description: "Post Request Query")
//
//        let requestDispatcher: RequestDispatcher = BaseRequestDispatcher(
//            request: HTTPBinGetRequest(),
//            builderType: BaseRequestBuilder.self,
//            strategy: JSONStrategy()
//        )
//
//        requestDispatcher.response()
//            .map { (response: Response) -> [String: Any] in
//                print(response)
//                return response.json.dictValue
//
//            }
//            .onSuccess { (json: [String: Any]) -> Void in
//                let configuration = requestDispatcher.request.configuration
//                guard
//                    // Headers Node
//                    let headers = json[HTTPBinKeys.headers.rawValue] as? [String: String],
//                    let host = headers[HTTPBinKeys.host.rawValue],
//                    let contentType = headers[HTTPBinKeys.contentType.rawValue],
//                    let getRequest = headers[HTTPBinKeys.getRequest.rawValue],
//
//                    let configurationContentTypeHeader = configuration.baseHeaders[HTTPBinKeys.contentType.rawValue] as? String,
//                    let requestGetRequestHeader = requestDispatcher.request.headers[HTTPBinKeys.getRequest.rawValue] as? String
//                else {
//                    XCTFail("Failed to get headers")
//                    return
//                }
//
//                XCTAssertTrue(requestDispatcher.request.configuration.host == host)
//                XCTAssertTrue(configurationContentTypeHeader == contentType)
//                XCTAssertTrue(requestGetRequestHeader == getRequest)
//                expectation.fulfill()
//
//            }
//            .onFailure { (error: NetworkingError) -> Void in
//                XCTFail(error.localizedDescription)
//            }
//
//        self.waitForExpectations(timeout: 5.0, handler: nil)
//    }

    func testGetRequest() {

        let expectation: XCTestExpectation = self.expectation(description: "Get Request Query")

        let request: Request = HTTPBinGetRequest()

        let dispatcher: RequestDispatcher = BaseRequestDispatcher(
            request: request,
            builderType: BaseRequestBuilder.self,
            strategy: JSONStrategy()
        )

        dispatcher.response()
            .map { (response: Response) -> HTTPBinBasicResponse in

                do {

                    return try self.decoder.decode(HTTPBinBasicResponse.self, from: response.data)

                } catch {
                    XCTFail("Failed to get args or url")
                    fatalError(error.localizedDescription)
                }

            }
            .onSuccess { (response: HTTPBinBasicResponse) -> Void in

                XCTAssertTrue(response.url == dispatcher.urlRequest.url!)
                XCTAssertTrue(response.args.this == request.parameters["this"]! as! String)
                XCTAssertTrue(response.args.what == request.parameters["what"]! as! String)
                XCTAssertTrue(response.args.why == request.parameters["why"]! as! String)
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

        let requestDispatcher: RequestDispatcher = BaseRequestDispatcher(
            request: HTTPBinPostRequest(),
            builderType: BaseRequestBuilder.self,
            strategy: FormURLEncodedStrategy()
        )

        requestDispatcher.response()
            .map { (response: Response) -> [String: Any] in
                return response.json.dictValue
            }
            .onSuccess { (json: [String: Any]) -> Void in
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

    func testMultiPartFormDataRequest() {

        let expectation: XCTestExpectation = self.expectation(description: "Post Request Query")

        let request: HTTPBinMultipartFormDataRequest = HTTPBinMultipartFormDataRequest()

        let dispatcher: RequestDispatcher = BaseRequestDispatcher(
            request: request,
            strategy: MultiPartFormDataStrategy(request: request)
        )

        dispatcher.response()
            .onSuccess { (response: Response) -> Void in
                print(response.json.dictValue)
                expectation.fulfill()
            }
            .onFailure { (error: NetworkingError) -> Void in
                XCTFail(error.localizedDescription)
            }

        self.waitForExpectations(timeout: 5.0, handler: nil)

    }

}
