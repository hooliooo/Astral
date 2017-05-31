//
//  RequestBuilder.swift
//  Astral
//
//  Created by Julio Alorro on 5/22/17.
//
//

/**
 A RequestBuilder uses the information of a Request to create an instance of URLRequest
*/
public protocol RequestBuilder {
    /**
     Initializer used to create a RequestBuilder
    */
    init(request: Request)

    /**
     The Request associated with the RequestBuilder
    */
    var request: Request { get }

    /**
     The URLRequest instance used when sending an HTTP network request
    */
    var urlRequest: URLRequest { get }
}
