//
//  UploadDelegate.swift
//  Astral
//
//  Created by Julio Miguel Alorro on 12/9/18.
//

import Foundation

open class UploadDelegate {

    public var taskCache: Set<AstralUploadTask> = []

    open func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {

        guard let uploadTask = self.taskCache.first(where: { $0.task == task }) else { return }
        uploadTask.progress.totalUnitCount = totalBytesExpectedToSend
        uploadTask.progress.completedUnitCount += bytesSent

        print("Bytes Sent from Dispatcher: \(totalBytesSent)")
    }

}

public struct AstralUploadTask: Hashable {

    public let progress: Progress
    public let task: URLSessionTask

    public var hashValue: Int {
        return task.taskIdentifier.hashValue
    }

}