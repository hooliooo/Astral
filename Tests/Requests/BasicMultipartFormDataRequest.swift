//
//  BasicMultipartFormDataRequest.swift
//  AstralTests
//
//  Created by Julio Alorro on 1/28/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Astral

struct BasicMultipartFormDataRequest: MultiPartFormDataRequest {

    let configuration: RequestConfiguration = MultiPartFormConfiguration()

    let method: HTTPMethod = .post

    let pathComponents: [String] = [
        "post"
    ]

    let parameters: [String: Any] = [
        "this": "that",
        "what": "where",
        "why": "what"
    ]

    var headers: Set<Header> {
        return [
            Header(key: Header.Field.custom("Get-Request"), value: Header.Value.custom("Yes")),
            Header(key: Header.Field.contentType, value: Header.Value.mediaType(MediaType.multipartFormData(self.boundary)))
        ]
    }

    let boundary: String = UUID().uuidString

    let files: [FormFile] = [
        FormFile(
            name: "file1",
            filename: "image1.png",
            contentType: "image/png",
            data: Data()
        ),
        FormFile(
            name: "file2",
            filename: "image2.png",
            contentType: "image/png",
            data: Data()
        )
    ]
}
