//
//  ViewController.swift
//  AstralApp
//
//  Created by Julio Miguel Alorro on 12/8/18.
//

import UIKit
import Astral

class MainVC: UIViewController {

    override func loadView() {
        self.view = MainView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.rootView.loadButton.addTarget(
            self,
            action: #selector(MainVC.loadButtonTapped),
            for: UIControl.Event.touchUpInside
        )

        self.rootView.helloWorldButton.addTarget(
            self,
            action: #selector(MainVC.helloWorldButtonTapped),
            for: UIControl.Event.touchUpInside
        )
    }

    private lazy var  dispatcher: BaseDelegateDispatcher = BaseDelegateDispatcher(
        configuration: URLSessionConfiguration.default,
        queue: self.queue,
        onUploadDidFinish: {
            print("Upload Finished")
        },
        onDownloadDidFinish: { (url: URL) -> Void in
            let data = try! Data(contentsOf: url, options: Data.ReadingOptions.alwaysMapped) // swiftlint:disable:this force_try
            let newURL: URL = FileManager.default.ast.cacheDirectory.appendingPathComponent("Test")
            try? data.write(to: newURL)
            print("New file location: \(newURL)")

        },
        isDebugMode: true
    )

    private let dispatcher2: BaseRequestDispatcher = BaseRequestDispatcher(builder: MultiPartFormDataBuilder())

    let queue: OperationQueue = {
        let op = OperationQueue()
        op.qualityOfService = QualityOfService.utility
        op.maxConcurrentOperationCount = 4
        return op
    }()

    var rootView: MainView { return self.view as! MainView } // swiftlint:disable:this force_cast

    @objc func helloWorldButtonTapped() {
        print("Hello World")
    }

    @objc func loadButtonTapped() {
        let request: MultiPartFormDataRequest = BasicMultipartFormDataRequest()
//        try! self.dispatcher.tryUploading(request: request) // swiftlint:disable:this force_try
        try! self.dispatcher2.multipartFormDataResponse( // swiftlint:disable:this force_try
            of: request,
            onSuccess: { (response: Response) -> Void in
                print("Success")
            },
            onFailure: { (error: NetworkingError) -> Void in
                print("Error")
            },
            onComplete: {}
        )
    }
}
