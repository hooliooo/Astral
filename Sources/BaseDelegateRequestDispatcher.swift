//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

open class BaseDelegateDispatcher: AstralRequestDispatcher {

    public enum ReadError: Error {
        /**
         Could not read file's size attribute.
         */
        case couldNotReadFileSize
    }

    public init(
        configuration: URLSessionConfiguration,
        queue: OperationQueue,
        whileUploading: @escaping (AstralTask) -> Void,
        onUploadDidFinish: @escaping () -> Void,
        whileDownloading: @escaping (AstralTask) -> Void,
        onDownloadDidFinish: @escaping (URL) -> Void,
        onError: @escaping (Error) -> Void,
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

    // MARK: Stored Properties
    private var _session: URLSession!
    public let whileUploading: (AstralTask) -> Void
    public let onUploadDidFinish: () -> Void
    public let whileDownloading: (AstralTask) -> Void
    public let onDownloadDidFinish: (URL) -> Void
    public let onError: (Error) -> Void

    private var taskCache: Set<AstralTask> = []

    // MARK: Computed Properties
    private var multipartFormDataBuilder: MultiPartFormDataBuilder {
        return self.builder as! MultiPartFormDataBuilder // swiftlint:disable:this force_cast
    }

    private var fileManager: FileManager {
        return self.multipartFormDataBuilder.fileManager
    }

    open override var session: URLSession {
        return self._session
    }

    public func upload(request: MultiPartFormDataRequest) throws {
        let urlRequest: URLRequest = self.multipartFormDataBuilder._urlRequest(of: request)
        let fileURL: URL = self.fileManager.ast.fileURL(of: request)
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

        astralTask.completedUnitCount += bytesSent
        astralTask.totalUnitCount = totalBytesExpectedToSend

        self.whileUploading(astralTask)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let astralTask = self.taskCache.first(where: { $0.sessionTask == dataTask }) else { return }

        self.onUploadDidFinish()

        if let request = astralTask.request as? MultiPartFormDataRequest {
            let fileURL: URL = self.fileManager.ast.fileURL(of: request)
            try? self.fileManager.removeItem(at: fileURL)
        }

        print(response)
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
        astralTask.totalUnitCount = totalBytesExpectedToWrite

        self.whileDownloading(astralTask)
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        guard let astralTask = self.taskCache.first(where: { $0.sessionTask == downloadTask }) else { return }
        self.taskCache.remove(astralTask)
        print("Location: \(location)")
        self.onDownloadDidFinish(location)
    }

}
