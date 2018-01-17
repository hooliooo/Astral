//
//  FormData.swift
//  Astral
//
//  Created by Julio Alorro on 1/17/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

public struct FormData {

    // MARK: Stored Properties
    /**
     The name parameter for the multipart form data
    */
    public let name: String

    /**
     The file name parameter for the multipart form data
    */
    public let filename: String

    /**
     The content type parameter for the multipart form data
    */
    public let contentType: String

    /**
     The data for the multipart form data
    */
    public let data: Data

}
