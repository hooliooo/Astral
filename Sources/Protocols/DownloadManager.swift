//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

/**
 A DownloadManager is the basic interface used to facilitate the management of URLSessionDownloadTasks during the download phase
*/
public protocol DownloadManager: URLSessionDownloadDelegate {

    /**
     Model is the type associated with the DownloadTracker class
    */
    associatedtype Model: Equatable

    /**
     Initializer
     - parameter queue: OperationQueue used by the URLSession for URLSessionDownloadDelegate methods
     - parameter session: URLSession instance used by the DownloadManager
    */
    init(queue: OperationQueue, session: URLSession)

    /**
     OperationQueue used by the URLSession for URLSessionDownloadDelegate methods
    */
    var queue: OperationQueue { get }

    /**
     URLSession instance used by the DownloadManager
    */
    var session: URLSession { get }

    /**
     The array of DownloadTrackers managed by the DownloadManager
    */
    var trackers: [AbstractDownloadTracker<Model>] { get }

}
