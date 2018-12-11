//
//  BaseDelegateDispatcher.swift
//  Astral
//
//  Created by Julio Miguel Alorro on 12/9/18.
//

import Foundation

open class BaseDelegateDispatcher: AstralRequestDispatcher {

    public init(
        configuration: URLSessionConfiguration,
        queue: OperationQueue,
        onUploadDidFinish: @escaping () -> Void,
        onDownloadDidFinish: @escaping (URL) -> Void,
        isDebugMode: Bool
    ) {
        self.onUploadDidFinish = onUploadDidFinish
        self.onDownloadDidFinish = onDownloadDidFinish
        super.init(builder: MultiPartFormDataBuilder(), isDebugMode: isDebugMode)

        self._session = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
    }

    // MARK: Stored Properties
    private var _session: URLSession!
    public let onUploadDidFinish: () -> Void
    public let onDownloadDidFinish: (URL) -> Void

    // MARK: Computed Properties
    private var multipartFormDataBuilder: MultiPartFormDataBuilder {
        return self.builder as! MultiPartFormDataBuilder // swiftlint:disable:this force_cast
    }

    open override var session: URLSession {
        return self._session
    }

    public func upload(request: MultiPartFormDataRequest) {
        let urlRequest: URLRequest = self.multipartFormDataBuilder.urlRequest(of: request)
        let fileURL: URL = FileManager.default.ast.fileURL(of: request)
        guard let data = try? self.multipartFormDataBuilder.data(of: request)
            else { print("Multipart form data was invalid"); return }

        FileManager.default.ast.writeAndCheck(data: data, of: request)

        let task: URLSessionUploadTask = self.session.uploadTask(with: urlRequest, fromFile: fileURL)
        self.add(task: task, with: request)
        task.resume()

    }

    public func tryUploading(request: MultiPartFormDataRequest) throws {
        let urlRequest: URLRequest = self.multipartFormDataBuilder.urlRequest(of: request)
        let fileURL: URL = FileManager.default.ast.fileURL(of: request)
        let data: Data = try self.multipartFormDataBuilder.data(of: request)

        try FileManager.default.ast.write(data: data, of: request)

        let task: URLSessionUploadTask = self.session.uploadTask(with: urlRequest, fromFile: fileURL)
        self.add(task: task, with: request)
        task.resume()
    }

}

extension BaseDelegateDispatcher: URLSessionDelegate {

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print(error as Any)
    }

}

extension BaseDelegateDispatcher: URLSessionDataDelegate {

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print(error as Any)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("Bytes Sent from Dispatcher: \(totalBytesSent)")
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.onUploadDidFinish()
        print("Has task: \(self.taskCache.keys.contains(dataTask)) \(#function)")
//        self.remove(task: dataTask)
        print("Has task: \(self.taskCache.keys.contains(dataTask)) \(#function)")
        print(response)
        completionHandler(.becomeDownload)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        let request = self.remove(task: dataTask)!
        print("Has Download task: \(self.taskCache.keys.contains(downloadTask)) \(#function)")
//        downloadTask.resume()
        self.add(task: downloadTask, with: request.1)
        print("Has Download task: \(self.taskCache.keys.contains(downloadTask)) \(#function)")
    }

}

extension BaseDelegateDispatcher: URLSessionDownloadDelegate {

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("Total Bytes Written: \(totalBytesWritten)")
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        print("Has task: \(self.taskCache.keys.contains(downloadTask)) \(#function)")
        self.remove(task: downloadTask)
        print("Has task: \(self.taskCache.keys.contains(downloadTask)) \(#function)")
        print("Location: \(location)")
        self.onDownloadDidFinish(location)
    }

}
