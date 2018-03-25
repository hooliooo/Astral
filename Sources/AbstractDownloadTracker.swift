//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 A base implementation of the DownloadTracking protocol
*/
open class AbstractDownloadTracker<Model: Equatable> {

    // MARK: Initializer
    /**
     Initializer for the DownloadTracker
     - parameter object: Object associated with the DownloadTracker instance
     - parameter tasks: URLSessionsDownloadTasks associated with the object instance
    */
    public init(object: Model, tasks: [URLSessionDownloadTask]) {
        guard type(of: self) != AbstractDownloadTracker.self else {
            fatalError("AbstractDownloadTracker instances cannot be created. Use subclasses instead")
        }

        self._object = object
        self._tasks = tasks
    }

    // MARK: Stored Properties
    private let _object: Model
    private var _tasks: [URLSessionDownloadTask]
    public let progress: Progress = Progress()

    // MARK: Computed Properties
    /**
     Object instance associated with the DownloadTracker instance
    */
    open var object: Model {
        return self._object
    }

}

extension AbstractDownloadTracker: DownloadTracking {

    // MARK: Properties
    open var tasks: [URLSessionDownloadTask] {
        return self._tasks
    }

    open var totalBytesToDownload: Int64 {
        self.progress.totalUnitCount = self._tasks
            .reduce(into: 0) { (result: inout Int64, task: URLSessionDownloadTask) -> Void in
                if let response = task.response {
                    result += response.expectedContentLength
                }
            }

        return self.progress.totalUnitCount
    }

    open var bytesWritten: Int64 {
        return self.progress.completedUnitCount
    }

    open var downloadPercentage: Double {
        return self.progress.fractionCompleted
    }

    open var isComplete: Bool {
        return self._tasks.contains { $0.state != URLSessionTask.State.completed } == false
    }

    // MARK: Methods
    open func add(bytes: Int64) {
        self.progress.completedUnitCount += bytes
    }

}

extension AbstractDownloadTracker: Equatable {

    open static func == (lhs: AbstractDownloadTracker<Model>, rhs: AbstractDownloadTracker<Model>) -> Bool {
        return lhs.object == rhs.object &&
            lhs.tasks == rhs.tasks &&
            lhs.totalBytesToDownload == rhs.totalBytesToDownload &&
            lhs.bytesWritten == rhs.bytesWritten
    }

}
