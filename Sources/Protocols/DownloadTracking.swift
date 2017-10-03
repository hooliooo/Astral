//
//  Astral
//  Copyright (c) 2017 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 A DownloadTracking object contains information about the downloading progress associated with it such as its URLSessionDownloadTasks,
 total bytes to download, the current bytes downloaded, and status.
*/
public protocol DownloadTracking {

    /**
     URLSessionDownloadTasks associated with the DownloadTracking instance
    */
    var tasks: [URLSessionDownloadTask] { get }

    /**
     Total bytes to be downloaded from the URLSessionDownloadTasks
    */
    var totalBytesToDownload: Int64 { get }

    /**
     Total bytes written so far associated with the download of URLSessionDownloadTasks
    */
    var bytesWritten: Int64 { get }

    /**
     The percentage of bytesWritten to the totalBytesToDownload
    */
    var downloadPercentage: Double { get }

    /**
     Checks whether all the URLSessionDownloadTasks are complete or not
    */
    var isComplete: Bool { get }

    /**
     Method used to increment bytesWritten.
     - parameter bytes: Bytes downloaded from a task associated with URLSessionDownloadTasks of this DownloadTracking instance.
    */
    func add(bytes: Int64)
}
