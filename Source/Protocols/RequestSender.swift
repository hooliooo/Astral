//
//  RequestSender.swift
//  Astral
//
//  Created by Julio Alorro on 5/23/17.
//
//

import BrightFutures

/**
 A RequestSender uses the URLRequest of the RequestBuilder to make an
 HTTP network request using the system's URLSession shared instance.
 */
public protocol RequestSender {
    /**
     Initializer using a Request
    */
    init(request: Request)

    /**
     Initializer using a RequestBuiler
    */
    init(builder: RequestBuilder)

    /**
     The Request associated with the RequestSender
    */
    var request: Request { get }

    /**
     The URLRequest associated with the RequestSender
    */
    var urlRequest: URLRequest { get }

    /**
     The method used to make an HTTP network request. Returns a Future.
    */
    func sendURLRequest() -> Future<Data, NetworkingError>
}
