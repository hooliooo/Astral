import XCTest
@testable import Astral

public class ResponseTests: XCTestCase {

    public override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    public override func tearDown() {
        super.tearDown()
    }

    // MARK: Stored Properties
    let decoder: JSONDecoder = JSONDecoder()
    let queue: DispatchQueue = DispatchQueue(
        label: "TestQueue",
        qos: DispatchQoS.utility,
        attributes: DispatchQueue.Attributes.concurrent
    )

    private lazy var dispatcher: BaseRequestDispatcher = BaseRequestDispatcher(queue: self.queue)

    // MARK: Instance Methods
    public func transform<U: Decodable>(response: Response) -> U {
        do {

            return try self.decoder.decode(U.self, from: response.data)

        } catch {
            XCTFail("Failed to get args or url")
            fatalError(error.localizedDescription)
        }
    }

    public func testHeaders() {
        let expectation: XCTestExpectation = self.expectation(description: "Header Test")

        let request: BasicGetRequest = BasicGetRequest()

        self.dispatcher.response(
            of: request,
            onSuccess: { [weak self] (_ response: Response) -> Void in
                guard let s = self else { return }

                let response: GetResponse = s.transform(response: response)

                let accept: Header = request.headers.filter { $0.key == .accept }.first!
                let contentType: Header = request.headers.filter { $0.key == .contentType }.first!
                let custom: Header = request.headers.filter { $0.key == Header.Field.custom("Get-Request") }.first!

                XCTAssertTrue(response.headers.accept == accept.value.stringValue)
                XCTAssertTrue(response.headers.contentType == contentType.value.stringValue)
                XCTAssertTrue(response.headers.custom == custom.value.stringValue)
                expectation.fulfill()

            },
            onFailure: { (_ error: NetworkingError) -> Void in
                XCTFail(error.localizedDescription)
            },
            onComplete: {
                print("Thread is Utility:", Thread.current.qualityOfService == QualityOfService.utility)
                print("Thread:", Thread.current.isMainThread)
            }
        )

        self.waitForExpectations(timeout: 5.0, handler: nil)
    }

    public func testGetRequest() {

        let expectation: XCTestExpectation = self.expectation(description: "Get Request Test")

        let request: Request = BasicGetRequest()

        self.dispatcher.response(
            of: request,
            onSuccess: { [weak self] (response: Response) -> Void in
                guard let s = self else { return }

                let response: GetResponse = s.transform(response: response)

                XCTAssertTrue(response.url == s.dispatcher.urlRequest(of: request).url!)
                XCTAssertTrue(response.args.this == request.parameters["this"]! as! String)
                XCTAssertTrue(response.args.what == request.parameters["what"]! as! String)
                XCTAssertTrue(response.args.why == request.parameters["why"]! as! String)
                expectation.fulfill()

            },
            onFailure: { (error: NetworkingError) -> Void in
                XCTFail(error.localizedDescription)
            },
            onComplete: {}
        )

        self.waitForExpectations(timeout: 5.0, handler: nil)

    }

    /**
     PUT and DELETE http methods produce identical results with POST request
    */
    public func testPostRequest() {
        let expectation: XCTestExpectation = self.expectation(description: "Post Request Query")

        let request: Request = BasicPostRequest()

        self.dispatcher.response(
            of: request,
            onSuccess: { [weak self] (response: Response) -> Void in
                guard let s = self else { return }

                let response: PostResponse = s.transform(response: response)

                XCTAssertTrue(response.url == s.dispatcher.urlRequest(of: request).url!)
                XCTAssertTrue(response.json.this == request.parameters["this"]! as! String)
                XCTAssertTrue(response.json.what == request.parameters["what"]! as! String)
                XCTAssertTrue(response.json.why == request.parameters["why"]! as! String)
                expectation.fulfill()
            },
            onFailure: { (error: NetworkingError) -> Void in
                XCTFail(error.localizedDescription)
            },
            onComplete: {}
        )

        self.waitForExpectations(timeout: 5.0, handler: nil)
    }

    public func testFormURLEncodedRequest() {
        let expectation: XCTestExpectation = self.expectation(description: "Post Request Query")

        let request: Request = FormURLEncodedPostRequest()

        let dispatcher: BaseRequestDispatcher = BaseRequestDispatcher(strategy: FormURLEncodedStrategy(), queue: self.queue)

        dispatcher.response(
            of: request,
            onSuccess: { [weak self] (response: Response) -> Void in
                guard let s = self else { return }

                let response: FormURLEncodedResponse = s.transform(response: response)

                XCTAssertTrue(response.url == dispatcher.urlRequest(of: request).url!)
                XCTAssertTrue(response.form.this == request.parameters["this"]! as! String)
                XCTAssertTrue(response.form.what == request.parameters["what"]! as! String)
                XCTAssertTrue(response.form.why == request.parameters["why"]! as! String)
                expectation.fulfill()
            },
            onFailure: { (error: NetworkingError) -> Void in
                XCTFail(error.localizedDescription)
            },
            onComplete: {}
        )

        self.waitForExpectations(timeout: 5.0, handler: nil)
    }

    public func testMultiPartFormDataRequest() {

        let expectation: XCTestExpectation = self.expectation(description: "Post Request Query")

        let request: MultiPartFormDataRequest = BasicMultipartFormDataRequest()

        let dispatcher: BaseRequestDispatcher = BaseRequestDispatcher(
            strategy: MultiPartFormDataStrategy(request: request)
        )

        dispatcher.response(
            of: request,
            onSuccess: { [weak self] (response: Response) -> Void in
                guard let s = self else { return }

                let response: MultipartFormDataResponse = s.transform(response: response)

                XCTAssertTrue(response.url == dispatcher.urlRequest(of: request).url!)
                XCTAssertTrue(response.form.this == request.parameters["this"]! as! String)
                XCTAssertTrue(response.form.what == request.parameters["what"]! as! String)
                XCTAssertTrue(response.form.why == request.parameters["why"]! as! String)
                XCTAssertFalse(response.files.isEmpty)
                expectation.fulfill()
            },
            onFailure: { (error: NetworkingError) -> Void in
                XCTFail(error.localizedDescription)
            },
            onComplete: {}
        )

        self.waitForExpectations(timeout: 5.0, handler: nil)

    }

}
