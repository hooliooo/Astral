//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.URLSessionTask
import class Foundation.Progress

/**
 A base implementation of the DownloadTracking protocol. An AbstractDownloadTracker is a data structure that stores information about the
 progress of the URLSessionDownloadTasks associated with its underlying Model. It uses a Progress object to manage the state of the
 URLSessionDownloadTasks.
*/
open class AbstractSessionTracker<Model: Equatable>: SessionTracking {

    // MARK: Initializer
    /**
     A base implementation of the DownloadTracking protocol. An AbstractDownloadTracker is a data structure that stores information about the
     progress of the URLSessionDownloadTasks associated with its underlying Model. It uses a Progress object to manage the state of the
     URLSessionDownloadTasks.
     - parameter object: The Model associated with the DownloadTracker.
     - parameter tasks: URLSessionsDownloadTasks associated with the Model.
    */
    public init(object: Model, tasks: [URLSessionTask]) {
        guard type(of: self) != AbstractSessionTracker.self else {
            fatalError("AbstractDownloadTracker instances cannot be created. Use subclasses instead")
        }

        self.object = object
        self.tasks = tasks
    }

    // MARK: Stored Properties
    public let object: Model
    public private(set) var tasks: [URLSessionTask]
    public let progress: Progress = Progress()

    // MARK: Computed Properties
    open var totalUnitCount: Int64 {
        self.progress.totalUnitCount = self.tasks
            .reduce(into: 0) { (result: inout Int64, task: URLSessionTask) -> Void in
                if let response = task.response {
                    result += response.expectedContentLength
                }
            }

        return self.progress.totalUnitCount
    }

    open var completedUnitCount: Int64 {
        return self.progress.completedUnitCount
    }

    open var fractionCompleted: Double {
        return self.progress.fractionCompleted
    }

    open var isComplete: Bool {
        return self.tasks.contains { $0.state != URLSessionTask.State.completed } == false
    }

    // MARK: Instance Methods
    open func add(unitCount: Int64) {
        self.progress.completedUnitCount += unitCount
    }

    open func add(task: URLSessionTask) {
        self.tasks.append(task)
    }

    open func remove(task: URLSessionTask) -> URLSessionTask? {
        if let idx = self.tasks.index(of: task) {
            let task: URLSessionTask = self.tasks.remove(at: idx)
            return task
        } else {
            return nil
        }
    }

}

extension AbstractSessionTracker: Equatable {

    public static func == (lhs: AbstractSessionTracker<Model>, rhs: AbstractSessionTracker<Model>) -> Bool {
        return lhs.object == rhs.object &&
            lhs.tasks == rhs.tasks &&
            lhs.totalUnitCount == rhs.totalUnitCount &&
            lhs.completedUnitCount == rhs.completedUnitCount
    }

}
