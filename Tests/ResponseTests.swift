import XCTest
@testable import Astral

public class ResponseTests: XCTestCase {

    // MARK: Static Properties
    private static let session: URLSession = {
        var configuration: URLSessionConfiguration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20.0
        configuration.timeoutIntervalForResource = 20.0
        configuration.httpAdditionalHeaders = ["User-Agent": "ios:com.julio.alorro.Astral:v2.0.4"]

        let queue: OperationQueue = OperationQueue()
        queue.qualityOfService = QualityOfService.utility

        let session: URLSession = URLSession(configuration: configuration, delegate: nil, delegateQueue: queue)
        return session
    }()

    public override class func setUp() {
        super.setUp()
        Astral.shared.configuration = Astral.Configuration(
            session: ResponseTests.session, fileManager: FileManager.default, boundary: UUID().uuidString
        )
    }

    // MARK: Stored Properties
    let decoder: JSONDecoder = JSONDecoder()

    private lazy var dispatcher: BaseRequestDispatcher = BaseRequestDispatcher()

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

        print(request)
        print(BasicMultipartFormDataRequest())

        self.dispatcher.response(
            of: request,
            onSuccess: { [weak self] (response: Response) -> Void in
                guard let s = self else { return }
                print(response.json.dictValue)
                let response: GetResponse = s.transform(response: response)

                let accept: Header = request.headers.filter { $0.key == .accept }.first!
                let contentType: Header = request.headers.filter { $0.key == .contentType }.first!
                let custom: Header = request.headers.filter { $0.key == Header.Key.custom("Get-Request") }.first!
                let userAgent: Header = request.configuration.baseHeaders.first(where: { $0.key == Header.Key.custom("User-Agent")})!

                XCTAssertTrue(response.headers.accept == accept.value.stringValue)
                XCTAssertTrue(response.headers.contentType == contentType.value.stringValue)
                XCTAssertTrue(response.headers.custom == custom.value.stringValue)
                XCTAssertTrue(response.headers.userAgent == userAgent.value.stringValue)
                expectation.fulfill()

            },
            onFailure: { (_ error: NetworkingError) -> Void in
                XCTFail(error.localizedDescription)
            },
            onComplete: {
                print("Thread is Utility:", Thread.current.qualityOfService == QualityOfService.utility)
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
                switch request.parameters {
                    case .dict(let parameters):
                        XCTAssertTrue(response.args.this == parameters["this"]! as! String)
                        XCTAssertTrue(response.args.what == parameters["what"]! as! String)
                        XCTAssertTrue(response.args.why == parameters["why"]! as! String)

                    case .array, .none:
                        XCTFail()
                }
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
                switch request.parameters {
                    case .dict(let parameters):
                        XCTAssertTrue(response.json.this == parameters["this"]! as! String)
                        XCTAssertTrue(response.json.what == parameters["what"]! as! String)
                        XCTAssertTrue(response.json.why == parameters["why"]! as! String)

                    case .array, .none:
                        XCTFail()
                }
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

        let dispatcher: BaseRequestDispatcher = BaseRequestDispatcher(strategy: FormURLEncodedStrategy())

        dispatcher.response(
            of: request,
            onSuccess: { [weak self] (response: Response) -> Void in
                guard let s = self else { return }

                let response: FormURLEncodedResponse = s.transform(response: response)

                XCTAssertTrue(response.url == dispatcher.urlRequest(of: request).url!)
                switch request.parameters {
                    case .dict(let parameters):
                        XCTAssertTrue(response.form.this == parameters["this"]! as! String)
                        XCTAssertTrue(response.form.what == parameters["what"]! as! String)
                        XCTAssertTrue(response.form.why == parameters["why"]! as! String)

                    case .array, .none:
                        XCTFail()
                }
                expectation.fulfill()
            },
            onFailure: { (error: NetworkingError) -> Void in
                XCTFail(error.localizedDescription)
            },
            onComplete: {}
        )

        self.waitForExpectations(timeout: 5.0, handler: nil)
    }

    public func testForMultipartFormDataRequest() {

        let expectation: XCTestExpectation = self.expectation(description: "Multipart form data")

        let dispatcher: BaseRequestDispatcher = BaseRequestDispatcher(strategy: MultiPartFormDataStrategy())
        let request: MultiPartFormDataRequest = BasicMultipartFormDataRequest()

        dispatcher.response(
            of: request,
            onSuccess: { [weak self] (response: Response) -> Void in
                guard let s = self else { return }
                let response: MultipartFormDataResponse = s.transform(response: response)

                XCTAssertTrue(response.url == dispatcher.urlRequest(of: request).url!)
                switch request.parameters {
                    case .dict(let parameters):
                        XCTAssertTrue(response.form.this == parameters["this"]! as! String)
                        XCTAssertTrue(response.form.what == parameters["what"]! as! String)
                        XCTAssertTrue(response.form.why == parameters["why"]! as! String)

                    case .array, .none:
                        XCTFail()
                }
                expectation.fulfill()
            },
            onFailure: { (error: NetworkingError) -> Void in
                XCTFail(error.localizedDescription)
            },
            onComplete: {}
        )

        self.waitForExpectations(timeout: 20.0, handler: nil)
    }

    public func testForMultipartFormDataRequest2() {

        let expectation: XCTestExpectation = self.expectation(description: "Multipart form data")

        let dispatcher: BaseRequestDispatcher = BaseRequestDispatcher(builder: MultiPartFormDataBuilder())
        let request: MultiPartFormDataRequest = BasicMultipartFormDataRequest()

        do {
            try dispatcher.multipartFormDataResponse(
                of: request,
                onSuccess: { [weak self] (response: Response) -> Void in
                    guard let s = self else { return }
                    let response: MultipartFormDataResponse = s.transform(response: response)

                    XCTAssertTrue(response.url == dispatcher.urlRequest(of: request).url!)
                    switch request.parameters {
                        case .dict(let parameters):
                            XCTAssertTrue(response.form.this == parameters["this"]! as! String)
                            XCTAssertTrue(response.form.what == parameters["what"]! as! String)
                            XCTAssertTrue(response.form.why == parameters["why"]! as! String)

                        case .array, .none:
                            XCTFail()
                    }
                    expectation.fulfill()
                },
                onFailure: { (error: NetworkingError) -> Void in
                    XCTFail(error.localizedDescription)
                },
                onComplete: {
                    XCTAssertTrue(Thread.current.qualityOfService == .utility)
                }
            )

        } catch {
            XCTFail(error.localizedDescription)
        }

        self.waitForExpectations(timeout: 20.0, handler: nil)
    }

}
