//
//  AstralAppTests.swift
//  AstralAppTests
//
//  Created by Julio Miguel Alorro on 12/8/18.
//

import XCTest
import Foundation
import Astral
import UIKit

class AstralAppTests: XCTestCase {

    // MARK: Static Properties
    private static let session: URLSession = {
        var configuration: URLSessionConfiguration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 600.0
        configuration.timeoutIntervalForResource = 600.0
        configuration.httpAdditionalHeaders = ["User-Agent": "ios:com.julio.alorro.Astral:v2.0.4"]
        let session: URLSession = URLSession(configuration: configuration)
        return session
    }()

    private let  dispatcher: BaseRequestDispatcher = BaseRequestDispatcher(
        builder: StreamRequestBuilder(),
        isDebugMode: true,
        queue: DispatchQueue.main
    )

    public override func setUp() {
        super.setUp()
        Astral.shared.configuration = Astral.Configuration(
            session: AstralAppTests.session, boundary: UUID().uuidString
        )
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

    // MARK: Instance Methods
    public func transform<U: Decodable>(response: Response) -> U {
        do {

            return try self.decoder.decode(U.self, from: response.data)

        } catch {
            XCTFail("Failed to get args or url")
            fatalError(error.localizedDescription)
        }
    }

    public func testMultiPartFormDataRequest() {

        let expectation: XCTestExpectation = self.expectation(description: "Post Request Query")

        let request: MultiPartFormDataRequest = BasicMultipartFormDataRequest()

        self.dispatcher.multipartFormDataResponse(
            of: request,
            onSuccess: { [weak self] (response: Response) -> Void in
                print(Thread.isMainThread)
//                print(response.json.stringValue)
                guard let s = self else { return }

                let response: MultipartFormDataResponse = s.transform(response: response)

                XCTAssertTrue(response.url == s.dispatcher.urlRequest(of: request).url!)

                switch request.parameters {
                    case .dict(let parameters):
                        // swiftlint:disable force_cast
                        XCTAssertTrue(response.form.this == parameters["this"]! as! String)
                        XCTAssertTrue(response.form.what == parameters["what"]! as! String)
                        XCTAssertTrue(response.form.why == parameters["why"]! as! String)

                    case .array, .none:
                        XCTFail("Invalid Parameters instance")
                }
                print(response.files)
                XCTAssertFalse(response.files.isEmpty)
                expectation.fulfill()
            },
            onFailure: { (error: NetworkingError) -> Void in
                XCTFail(error.localizedDescription)
        },
            onComplete: {}
        )

        self.waitForExpectations(timeout: 600.0, handler: nil)

    }

}
