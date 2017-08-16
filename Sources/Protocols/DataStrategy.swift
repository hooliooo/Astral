//
//  DataStrategy.swift
//  Astral
//
//  Created by Julio Alorro on 8/16/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

public protocol DataStrategy {

    /**
     The method transforms the object instance into an optional Data
     - parameter object: The object to be transformed in to Data
    */
    func createHTTPBody(from object: Any) -> Data?

}
