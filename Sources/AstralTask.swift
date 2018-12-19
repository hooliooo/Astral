//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//


import class Foundation.URLSessionTask
import class Foundation.Progress

public class AstralTask {

    // MARK: Intiializer
    public init(sessionTask: URLSessionTask, request: Request, progress: Progress) {
        self.sessionTask = sessionTask
        self.request = request
        self.progress = progress
    }

    // MARK: Stored Properties
    /**
     The URLSessionTask instance. Represents the networking request.
    */
    public let sessionTask: URLSessionTask

    /**
     The Request instance used to create the sessionTask.
    */
    public let request: Request

    /**
     The Progress instance used to track the completion of the sessionTask.
    */
    public let progress: Progress

    // MARK: Computed Properties
    public var completedUnitCount: Int64 {
        return self.progress.completedUnitCount
    }

    public var totalUnitCount: Int64 {
        return self.progress.totalUnitCount
    }

}

extension AstralTask: Hashable {
    public var hashValue: Int {
        return self.sessionTask.hashValue
    }

    public static func == (lhs: AstralTask, rhs: AstralTask) -> Bool {
        return lhs.sessionTask == rhs.sessionTask
    }
}
