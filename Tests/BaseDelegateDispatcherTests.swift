//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import XCTest
@testable import Astral

class BaseDelegateDispatcherTests: XCTestCase {

    func testWhileUploadingAndOnUploadDidFinish() {
        let expectationForWhileUploading = self.expectation(
            description: "whileUploading closure should execute until 100%"
        )
        let expectationForUploadingDidFinish = self.expectation(
            description: "onUploadDidFinish should yield an AstralTask with 100% fraction completed"
        )

        let dispatcher: BaseDelegateDispatcher = BaseDelegateDispatcher(
            configuration: URLSessionConfiguration.default,
            queue: {
                let queue: OperationQueue = OperationQueue()
                queue.qualityOfService = QualityOfService.utility
                return queue
            }(),
            whileUploading: { (task: AstralTask) -> Void in
                guard task.fractionCompleted == 1.0 else { return }
                expectationForWhileUploading.fulfill()
            },
            onUploadDidFinish: { (task: AstralTask) -> Void in
                guard task.fractionCompleted == 1.0 else { XCTFail("Upload wasn't 100% when it finished"); return }
                expectationForUploadingDidFinish.fulfill()
            },
            whileDownloading: { _ in },
            onDownloadDidFinish: { _ in },
            onError: { _ in },
            isDebugMode: false
        )

        do {
            try dispatcher.upload(request: BasicMultipartFormDataRequest())
        } catch let error {
            XCTFail("Upload failed: \(error)")
        }

        self.waitForExpectations(timeout: 20.0, handler: nil)
    }

    func testWhileDownloadingAndOnDownloadDidFinish() {
        let expectationWhileDownloading = self.expectation(
            description: "whileDownloading closure should execute until 100%"
        )
        let expectationForDownloadingDidFinish = self.expectation(
            description: "onDownloadDidFinish should yield an AstralTask with 100% fraction completed"
        )

        let dispatcher: BaseDelegateDispatcher = BaseDelegateDispatcher(
            configuration: URLSessionConfiguration.default,
            queue: {
                let queue: OperationQueue = OperationQueue()
                queue.qualityOfService = QualityOfService.utility
                return queue
            }(),
            whileUploading: { _ in },
            onUploadDidFinish: { _ in },
            whileDownloading: { (task: AstralTask) -> Void in
                guard task.fractionCompleted == 1.0 else { return }
                XCTAssertTrue(Thread.current.qualityOfService == .utility)
                expectationWhileDownloading.fulfill()
            },
            onDownloadDidFinish: { (url: URL) -> Void in
                print(url)
                XCTAssertTrue(Thread.current.qualityOfService == .utility)
                expectationForDownloadingDidFinish.fulfill()
            },
            onError: { _ in },
            isDebugMode: true
        )

        do {
            try dispatcher.upload(request: BasicMultipartFormDataRequest())
        } catch let error {
            XCTFail("Download failed: \(error)")
        }

        self.waitForExpectations(timeout: 20.0, handler: nil)
    }

}
