//
//  HTTPBinMultipartFormDataRequest.swift
//  AstralTests
//
//  Created by Julio Alorro on 1/28/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Astral

struct HTTPBinMultipartFormDataRequest: MultiPartFormDataRequest {

    let configuration: RequestConfiguration = MultiPartFormConfiguration()

    let method: HTTPMethod = .post

    let pathComponents: [String] = [
        "post"
    ]

    let parameters: [String: Any] = [
        "this": "that"
    ]

    var headers: Set<Header> {
        return Set<Header>(arrayLiteral:
            Header(key: Header.Field.custom("Post-Request"), value: Header.Value.custom("Yes")),
            Header(key: Header.Field.contentType, value: Header.Value.mediaType(MediaType.multipartFormData(self.boundary)))
        )
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
