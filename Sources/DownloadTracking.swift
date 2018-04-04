//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 A DownloadTracking object contains information about its downloading progress such as its URLSessionDownloadTasks,
 total bytes to download, the current bytes downloaded, and status.
*/
public protocol SessionTracking {

    /**
     URLSessionDownloadTasks associated with the DownloadTracking instance.
    */
    var tasks: [URLSessionTask] { get }

    /**
     The Progress object managing the information about the state of the tasks.
    */
    var progress: Progress { get }

    /**
     The total bytes to be downloaded from the tasks.
    */
    var totalUnitCount: Int64 { get }

    /**
     The total bytes that have been completed so far.
    */
    var completedUnitCount: Int64 { get }

    /**
     The percentage of the totalUnitCount that is completed.
    */
    var fractionCompleted: Double { get }

    /**
     Checks whether all the URLSessionDownloadTasks are complete or not.
    */
    var isComplete: Bool { get }

    /**
     Method used to increment the progress of the tasks.
     - parameter unitCount: The bytes of a download to be incremented to the Progress instance's completeUnitCount property.
    */
    func add(unitCount: Int64)
}
