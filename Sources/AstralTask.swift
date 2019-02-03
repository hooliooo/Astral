//
//  Astral
//  Copyright (c) 2017-2019 Julio Miguel Alorro
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
    /**
     The completedUnitCount of the Progress instance.
    */
    public var completedUnitCount: Int64 {
        get { return self.progress.completedUnitCount }

        set { self.progress.completedUnitCount = newValue }
    }

    /**
     The totalUnitCount of the Progress instance.
    */
    public var totalUnitCount: Int64 {
        get { return self.progress.totalUnitCount }

        set { self.progress.totalUnitCount = newValue }
    }

    /**
     The fractionCompleted of the Progress instance.
    */
    public var fractionCompleted: Double {
        return self.progress.fractionCompleted
    }

}

extension AstralTask: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.sessionTask)
    }

    public static func == (lhs: AstralTask, rhs: AstralTask) -> Bool {
        return lhs.sessionTask == rhs.sessionTask
    }
}
