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
import class Foundation.URLSessionTask
import class Foundation.URLSessionDataTask
import class Foundation.URLSessionDownloadTask
import class Foundation.URLSessionUploadTask
import class Foundation.Progress
import class Foundation.URLResponse
import class Foundation.NSNumber

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
        onError: @escaping (_ error: Error) -> Void,
        isDebugMode: Bool
    ) {
        self.whileUploading = whileUploading
        self.onUploadDidFinish = onUploadDidFinish
        self.whileDownloading = whileDownloading
        self.onDownloadDidFinish = onDownloadDidFinish
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

    private func printValue(_ value: CustomStringConvertible) {
        if self.isDebugMode {
            print(value)
        }
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

extension BaseDelegateDispatcher: URLSessionDataDelegate {

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error else { return }
        self.onError(error)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let astralTask = self.taskCache.first(where: { $0.sessionTask == task }) else { return }
        astralTask.completedUnitCount = totalBytesSent

        self.printValue(
            """
            didSendBodyData: \(bytesSent)
            totalBytesSent: \(totalBytesSent)
            totalBytesExpectedToSend: \(totalBytesExpectedToSend)
            totalUnitCount: \(astralTask.completedUnitCount)
            percentage: \(Double(totalBytesSent / totalBytesExpectedToSend))
            """
        )

        astralTask.totalUnitCount = totalBytesExpectedToSend
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
                self.onError(error)
            }
        }

        self.printValue(response)
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
        astralTask.completedUnitCount += bytesWritten

        self.printValue(
            """
            bytesWritten: \(bytesWritten),
            totalBytesWritten: \(totalBytesWritten),
            totalBytesExpectedToWrite: \(totalBytesExpectedToWrite)
            totalUnitCount: \(astralTask.completedUnitCount)
            percentage: \(Double(totalBytesWritten / totalBytesExpectedToWrite))
            """
        )

        astralTask.totalUnitCount = totalBytesExpectedToWrite
        self.whileDownloading(astralTask)
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let astralTask = self.taskCache.first(where: { $0.sessionTask == downloadTask }) else { return }
        self.taskCache.remove(astralTask)
        self.printValue("Location: \(location)")
        self.onDownloadDidFinish(location)
    }

}
