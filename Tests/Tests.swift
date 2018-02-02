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
        super.tearDown()
    }

    let decoder: JSONDecoder = JSONDecoder()

    func testHeaders() {
        let expectation: XCTestExpectation = self.expectation(description: "Post Request Query")

        let dispatcher = BaseRequestDispatcher(request: BasicGetRequest())

        dispatcher.response()
            .map { [unowned self] (response: Response) -> GetResponse in

                do {

                    return try self.decoder.decode(GetResponse.self, from: response.data)

                } catch {
                    XCTFail("Failed to get args or url")
                    fatalError(error.localizedDescription)
                }

            }
            .onSuccess { (response: GetResponse) -> Void in

                let accept: Header = dispatcher.request.headers.filter { $0.key == .accept }.first!
                let contentType: Header = dispatcher.request.headers.filter { $0.key == .contentType }.first!
                let custom: Header = dispatcher.request.headers.filter { $0.key == Header.Field.custom("Get-Request") }.first!

                XCTAssertTrue(response.headers.accept == accept.value.stringValue)
                XCTAssertTrue(response.headers.contentType == contentType.value.stringValue)
                XCTAssertTrue(response.headers.custom == custom.value.stringValue)
                expectation.fulfill()
            }
            .onFailure { (error: NetworkingError) -> Void in
                XCTFail(error.localizedDescription)
            }

        self.waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testGetRequest() {

        let expectation: XCTestExpectation = self.expectation(description: "Get Request Query")

        let request: Request = BasicGetRequest()

        let dispatcher: RequestDispatcher = BaseRequestDispatcher(request: request)

        dispatcher.response()
            .map { (response: Response) -> GetResponse in

                do {

                    return try self.decoder.decode(GetResponse.self, from: response.data)

                } catch {
                    XCTFail("Failed to get args or url")
                    fatalError(error.localizedDescription)
                }

            }
            .onSuccess { (response: GetResponse) -> Void in

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

        let request: Request = BasicPostRequest()

        let dispatcher: RequestDispatcher = BaseRequestDispatcher(request: request)

        dispatcher.response()
            .map { (response: Response) -> PostResponse in
                do {

                    return try self.decoder.decode(PostResponse.self, from: response.data)

                } catch {
                    XCTFail("Failed to get json or url")
                    fatalError(error.localizedDescription)
                }
            }
            .onSuccess { (response: PostResponse) -> Void in
                XCTAssertTrue(response.url == dispatcher.urlRequest.url!)
                XCTAssertTrue(response.json.this == request.parameters["this"]! as! String)
                XCTAssertTrue(response.json.what == request.parameters["what"]! as! String)
                XCTAssertTrue(response.json.why == request.parameters["why"]! as! String)
                expectation.fulfill()
            }
            .onFailure { (error: NetworkingError) -> Void in
                XCTFail(error.localizedDescription)
            }

        self.waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testFormURLEncodedRequest() {
        let expectation: XCTestExpectation = self.expectation(description: "Post Request Query")

        let request: Request = FormURLEncodedPostRequest()

        let dispatcher: RequestDispatcher = BaseRequestDispatcher(request: request, strategy: FormURLEncodedStrategy())

        dispatcher.response()
            .map { (response: Response) -> FormURLEncodedResponse in
                do {

                    return try self.decoder.decode(FormURLEncodedResponse.self, from: response.data)

                } catch {
                    XCTFail("Failed to get form or url")
                    fatalError(error.localizedDescription)
                }
            }
            .onSuccess { (response: FormURLEncodedResponse) -> Void in
                XCTAssertTrue(response.url == dispatcher.urlRequest.url!)
                XCTAssertTrue(response.form.this == request.parameters["this"]! as! String)
                XCTAssertTrue(response.form.what == request.parameters["what"]! as! String)
                XCTAssertTrue(response.form.why == request.parameters["why"]! as! String)
                expectation.fulfill()
            }
            .onFailure { (error: NetworkingError) -> Void in
                XCTFail(error.localizedDescription)
            }

        self.waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testMultiPartFormDataRequest() {

        let expectation: XCTestExpectation = self.expectation(description: "Post Request Query")

        let request: MultiPartFormDataRequest = BasicMultipartFormDataRequest()

        let dispatcher: RequestDispatcher = BaseRequestDispatcher(
            request: request,
            strategy: MultiPartFormDataStrategy(request: request)
        )

        dispatcher.response()
            .map { (response: Response) -> MultipartFormDataResponse in
                do {

                    return try self.decoder.decode(MultipartFormDataResponse.self, from: response.data)

                } catch {
                    XCTFail("Failed to get form or url")
                    fatalError(error.localizedDescription)
                }
            }
            .onSuccess { (response: MultipartFormDataResponse) -> Void in
                XCTAssertTrue(response.url == dispatcher.urlRequest.url!)
                XCTAssertTrue(response.form.this == request.parameters["this"]! as! String)
                XCTAssertTrue(response.form.what == request.parameters["what"]! as! String)
                XCTAssertTrue(response.form.why == request.parameters["why"]! as! String)
                XCTAssertFalse(response.files.isEmpty)
                expectation.fulfill()
            }
            .onFailure { (error: NetworkingError) -> Void in
                XCTFail(error.localizedDescription)
            }

        self.waitForExpectations(timeout: 5.0, handler: nil)

    }

}
