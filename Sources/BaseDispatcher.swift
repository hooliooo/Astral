//
//  BaseDispatcher.swift
//  Astral
//
//  Created by Julio Miguel Alorro on 3/4/18.
//

import Foundation

public protocol BaseDispatcher: RequestDispatcher {

    /**
     The DispatchQueue where the URLSessionDataTask will be created and executed. Default is DispatchQueue.main
    */
    var queue: DispatchQueue { get }

    /**
     Creates and executes a URLSessionDataTask with onSuccess, onFailure, and onComplete completion handlers.
     Executed Asynchronously on the DispatchQueue.
     - parameter request:    The Request instance used to build the URLRequest from the RequestBuilder.
     - parameter onSuccess:  The callback that is executed when the completion handler returns valid Data.
     - parameter response: The Data from the completion handler transformed as a Response.
     - parameter onFailure:  The callback that is executed when the completion handler return an Error.
     - parameter error:  The Error from the completion handler transformed as a NetworkingError.
     - parameter onComplete: The callback that is executed when the completion handler returns either Data or en Error.
    */
    func response(
        of request: Request,
        onSuccess: @escaping (_ response: Response) -> Void,
        onFailure: @escaping (_ error: NetworkingError) -> Void,
        onComplete: @escaping () -> Void
    )

}
