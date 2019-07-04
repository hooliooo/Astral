//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.URLSession
import class Foundation.URLSessionConfiguration
import class Foundation.OperationQueue
import struct Foundation.URL
import struct Foundation.URLRequest
import struct Foundation.FileAttributeKey
import class Foundation.FileManager
import protocol Foundation.URLSessionDelegate
import protocol Foundation.URLSessionDataDelegate
import protocol Foundation.URLSessionDownloadDelegate
import protocol Foundation.URLSessionTaskDelegate
import class Foundation.URLSessionTask
import class Foundation.URLSessionTaskMetrics
import class Foundation.URLSessionDataTask
import class Foundation.URLSessionDownloadTask
import class Foundation.URLSessionUploadTask
import class Foundation.Progress
import class Foundation.URLResponse
import class Foundation.NSNumber
import os

/**
 BaseDelegateDispatcher is a RequestDispatcher that is the delegate of the URLSession it manages. It's used when you need finer control of
 processing URLSessionTasks.
*/
open class BaseDelegateDispatcher: AstralRequestDispatcher {

    /**
     Erros related to FileAttributes
    */
    public enum ReadError: Error {
        /**
         Could not read file's size attribute.
         */
        case couldNotReadFileSize
    }

    public enum ResponseError: Error {

        /**
         Could not determine the response's expectedContentLength, which could be a server-side error
        */
        case unknownContentLength

        var intValue: Int {
            switch self {
                case .unknownContentLength:
                    return -1
            }
        }
    }

    // MARK: Initializer
    /**
     BaseDelegateDispatcher is a RequestDispatcher that is the delegate of the URLSession it manages. It's used when you need finer control of
     processing URLSessionTasks.
     - parameters:
        - whileUploading:        The closure that is executed when urlSession(_:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)
                                 is called.
        - task:                  The AstralTask related to the URLSessionTask.
        - onUploadDidFinish:     The closure that is executed when urlSession(_:dataTask:didReceive:completionHandler:)
                                 is called.
        - onDownloadDidFinish:
        - whileDownloading:      The closure that is executed when
                                 urlSession(_:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:) is called.
        - onDownloadDidFinish:   The closure that is executed when urlSession(_:downloadTask:didFinishDownloadingTo)
                                 is called.
        - url:                   The URL of the of the downloaded data by the URLSessionDownloadTask.
        - onError:               The closure that is executed when
                                 urlSession(_:task:didCompleteWithError) and urlSession(_:didBecomeInvalidWithError) are called.
        - error:                 The error that occured with the URLSessionTask.
        - isDebugMode:           If true, the console will print out information related to the http networking request. If false, prints nothing.
    */
    public init(
        configuration: URLSessionConfiguration,
        queue: OperationQueue,
        whileUploading: @escaping (_ task: AstralTask) -> Void,
        onUploadDidFinish: @escaping (_ task: AstralTask) -> Void,
        whileDownloading: @escaping (_ task: AstralTask) -> Void,
        onDownloadDidFinish: @escaping (_ url: URL) -> Void,
        onMetricsCollected: @escaping (_ metrics: URLSessionTaskMetrics) -> Void,
        onError: @escaping (_ error: Error) -> Void,
        isDebugMode: Bool
    ) {
        self.whileUploading = whileUploading
        self.onUploadDidFinish = onUploadDidFinish
        self.whileDownloading = whileDownloading
        self.onDownloadDidFinish = onDownloadDidFinish
        self.onMetricsCollected = onMetricsCollected
        self.onError = onError
        super.init(builder: MultiPartFormDataBuilder(), isDebugMode: isDebugMode)

        self._session = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
    }

    deinit {
        self._session.invalidateAndCancel()
    }

    // MARK: Stored Properties
    private var _session: URLSession! // swiftlint:disable:this implicitly_unwrapped_optional
    /**
     Executed when urlSession(_:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)
     is called.
    */
    public let whileUploading: (AstralTask) -> Void

    /**
     Executed when urlSession(_:dataTask:didReceive:completionHandler:)
     is called.
    */
    public let onUploadDidFinish: (AstralTask) -> Void

    /**
     Executed urlSession(_:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:) is called.
    */
    public let whileDownloading: (AstralTask) -> Void

    /**
     Executed when urlSession(_:downloadTask:didFinishDownloadingTo)
     is called.
    */
    public let onDownloadDidFinish: (URL) -> Void

    /**
     Excuted when urlSession(_:task:didFinishCollecting metrics:) is called
    */
    public let onMetricsCollected: (URLSessionTaskMetrics) -> Void

    /**
     Executed when urlSession(_:task:didCompleteWithError) and urlSession(_:didBecomeInvalidWithError) are called.
    */
    public let onError: (Error) -> Void

    /**
     Tasks executed and managed by this dispatcher.
    */
    private var taskCache: Set<AstralTask> = []

    // MARK: Computed Properties
    private var multipartFormDataBuilder: MultiPartFormDataBuilder {
        return self.builder as! MultiPartFormDataBuilder // swiftlint:disable:this force_cast
    }

    private var fileManager: FileManager {
        return self.multipartFormDataBuilder.fileManager
    }

    /**
     The URLSession managed by this BaseDelegateDispatcher. The URLSession's delegate is this BaseDelegateDispatcher.
     The delegateQueue is the OperationQueue that was used to initialize this BaseDelegateDispatcher.
    */
    override open var session: URLSession {
        return self._session
    }

    /**
     Uploads the multipart form data http request. This method throws.
     - parameters:
        - request: The MultiPartFormDataRequest to be uploaded.
    */
    public func upload(request: MultiPartFormDataRequest) throws {
        let urlRequest: URLRequest = self.multipartFormDataBuilder._urlRequest(of: request)
        let fileURL: URL = self.fileManager.ast.fileURL(of: request)

        switch self.fileManager.fileExists(atPath: fileURL.path) {
            case true:
                try self.fileManager.removeItem(at: fileURL)
            case false:
                break
        }

        try self.multipartFormDataBuilder.strategy.writeData(to: fileURL, for: request)

        let fileAttributes: [FileAttributeKey: Any] = try self.fileManager
            .attributesOfItem(atPath: fileURL.path)

        guard let fileSize = fileAttributes[FileAttributeKey.size] as? NSNumber else {
            throw BaseDelegateDispatcher.ReadError.couldNotReadFileSize
        }

        let progress: Progress = Progress(totalUnitCount: fileSize.int64Value)
        let task: URLSessionUploadTask = self.session.uploadTask(with: urlRequest, fromFile: fileURL)

        self.taskCache.insert(
            AstralTask(
                sessionTask: task,
                request: request,
                progress: progress
            )
        )

        task.resume()

    }

}

extension BaseDelegateDispatcher: URLSessionDelegate {

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error else { return }
        self.onError(error)
    }

}

extension BaseDelegateDispatcher: URLSessionTaskDelegate {

    public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        guard let astralTask = self.taskCache.first(where: { $0.sessionTask == task }) else { return }
        os_log("Redirect count: %d", log: Astral.shared.logger, type: OSLogType.info, metrics.redirectCount)
        os_log("Task Interval: %s", log: Astral.shared.logger, type: OSLogType.info, metrics.taskInterval.description)

        for transactionMetric in metrics.transactionMetrics {

            astralTask.totalUnitCount = transactionMetric.response?.expectedContentLength ?? 0

            os_log(
                """
                transactionMetric:
                %@
                """,
                log: Astral.shared.logger,
                type: OSLogType.info,
                transactionMetric.description
            )

        }
    }

}

extension BaseDelegateDispatcher: URLSessionDataDelegate {

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error else { return }
        self.onError(error)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let astralTask = self.taskCache.first(where: { $0.sessionTask == task }) else { return }
        astralTask.completedUnitCount = totalBytesSent

        let completedUnitCount: Int64 = astralTask.completedUnitCount
        let percentage: Double = max(Double(totalBytesSent) / Double(totalBytesExpectedToSend), 0.0)

        os_log(
            """

            didSendBodyData: %{public}d
            totalBytesSent: %{public}d
            totalBytesExpectedToSend: %{public}d
            totalUnitCount: %{public}d
            percentage: %{public}.2f

            """,
            log: Astral.shared.logger,
            type: OSLogType.info,
            bytesSent,
            totalBytesSent,
            totalBytesExpectedToSend,
            completedUnitCount,
            percentage
        )

        astralTask.totalUnitCount = totalBytesExpectedToSend

        if percentage == 1.0 {
            print("Uploaded at 100%: \(percentage)")
        }
        self.whileUploading(astralTask)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {

        guard let astralTask = self.taskCache.first(where: { $0.sessionTask == dataTask }) else { return }
        self.onUploadDidFinish(astralTask)

        if let request = astralTask.request as? MultiPartFormDataRequest {
            let fileURL: URL = self.fileManager.ast.fileURL(of: request)
            do {
                 try self.fileManager.removeItem(at: fileURL)
            } catch {
                os_log("Could not remove file after receiving response", log: Astral.shared.logger, type: OSLogType.error)
                self.onError(error)
            }
        }

        os_log("Did receive response: %@", log: Astral.shared.logger, type: OSLogType.info, response)

        if response.expectedContentLength == ResponseError.unknownContentLength.intValue {
            print("\(astralTask.sessionTask.countOfBytesExpectedToReceive)")
            os_log("Unknown Content Length from response", log: Astral.shared.logger, type: OSLogType.info)
        }

        completionHandler(.becomeDownload)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        guard let astralTask = self.taskCache.first(where: { $0.sessionTask == dataTask }) else { return }
        let newAstralTask: AstralTask = AstralTask(sessionTask: downloadTask, request: astralTask.request, progress: Progress())
        self.taskCache.remove(astralTask)
        self.taskCache.insert(newAstralTask)
    }

}

extension BaseDelegateDispatcher: URLSessionDownloadDelegate {

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        guard let astralTask = self.taskCache.first(where: { $0.sessionTask == downloadTask }) else { return }

        if totalBytesExpectedToWrite != ResponseError.unknownContentLength.intValue {
            astralTask.totalUnitCount = totalBytesExpectedToWrite
            astralTask.completedUnitCount += bytesWritten
        } else {
            if astralTask.totalUnitCount != 0 { // was set in metrics method
                astralTask.completedUnitCount = totalBytesWritten
            }
        }

        let completedUnitCount: Int64 = astralTask.completedUnitCount

        let percentage: Double = {
            if astralTask.totalUnitCount != 0 {
                return Double(totalBytesWritten) / Double(astralTask.totalUnitCount)
            } else {
                return 0.0
            }
        }()

        os_log(
            """

            bytesWritten: %{public}d
            totalBytesWritten: %{public}d
            totalBytesExpectedToWrite: %{public}d
            completedUnitCount: %{public}d
            percentage: %{public}.2f

            """,
            log: Astral.shared.logger,
            type: OSLogType.info,
            bytesWritten,
            totalBytesWritten,
            totalBytesExpectedToWrite,
            completedUnitCount,
            percentage
        )

        self.whileDownloading(astralTask)
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let astralTask = self.taskCache.first(where: { $0.sessionTask == downloadTask }) else { return }
        self.taskCache.remove(astralTask)
        os_log("Downloaded file to %{public}@", log: Astral.shared.logger, type: OSLogType.info, location.absoluteString)
        self.onDownloadDidFinish(location)
    }

}
