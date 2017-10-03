//
//  DownloadTracker.swift
//  Astral
//
//  Created by Julio Alorro on 9/18/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

/**
 A base implementation of the DownTracking protocol
*/
open class DownloadTracker<Model: Equatable> {

    // MARK: Initializer
    /**
     Initializer for the DownloadTracker
     - parameter object: Object associated with the DownloadTracker instance
     - parameter tasks: URLSessionsDownloadTasks associated with the object instance
    */
    public init(object: Model, tasks: [URLSessionDownloadTask]) {
        self._object = object
        self._tasks = tasks
    }

    // MARK: Stored Properties
    private let _object: Model
    private var _tasks: [URLSessionDownloadTask]
    private var _bytesWritten: Int64 = 0

    // MARK: Computed Properties
    /**
     Object instance associated with the DownloadTracker instance
    */
    open var object: Model {
        return self._object
    }

}

extension DownloadTracker: DownloadTracking {

    // MARK: Properties
    open var tasks: [URLSessionDownloadTask] {
        return self._tasks
    }

    open var totalBytesToDownload: Int64 {
        return self._tasks.reduce(into: 0) { (result: inout Int64, task: URLSessionDownloadTask) -> Void in
            if let response = task.response {
                result += response.expectedContentLength
            }
        }
    }

    open var bytesWritten: Int64 {
        return self._bytesWritten
    }

    open var downloadPercentage: Double {
        return Double(self._bytesWritten) / Double(self.totalBytesToDownload)
    }

    open var isComplete: Bool {
        return self._tasks.contains { $0.state != URLSessionTask.State.completed } == false
    }

    // MARK: Methods
    open func add(bytes: Int64) {
        fatalError("add(bytes:) method must be overridden with your implementation")
    }

}

extension DownloadTracker: Equatable {

    open static func == (lhs: DownloadTracker<Model>, rhs: DownloadTracker<Model>) -> Bool {
        return lhs.object == rhs.object &&
            lhs.tasks == rhs.tasks &&
            lhs.totalBytesToDownload == rhs.totalBytesToDownload &&
            lhs.bytesWritten == rhs.bytesWritten
    }

}
