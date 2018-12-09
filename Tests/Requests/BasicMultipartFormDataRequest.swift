//
//  BasicMultipartFormDataRequest.swift
//  AstralTests
//
//  Created by Julio Alorro on 1/28/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Astral
import UIKit

struct BasicMultipartFormDataRequest: MultiPartFormDataRequest {

    let configuration: RequestConfiguration = MultiPartFormConfiguration()

    let method: HTTPMethod = .post

    let pathComponents: [String] = [
        "post"
    ]

    let parameters: Parameters = Parameters.dict([
        "this": "that",
        "what": "where",
        "why": "what"
    ])

    var headers: Set<Header> {

        return [
            Header(key: Header.Field.custom("Get-Request"), value: Header.Value.custom("Yes")),
            Header(key: Header.Field.contentType, value: Header.Value.mediaType(MediaType.multipartFormData(Astral.shared.boundary))),
            Header(key: Header.Field.custom("Connection"), value: Header.Value.custom("Keep-Alive"))
        ]
    }

    public var files: [FormFile] {
        return [
            FormFile(
                name: "file1",
                fileName: "image1.png",
                contentType: "image/png",
                data: UIImage(named: "pic1")!.pngData()!,
                parameters: self.parameters
            ),
            FormFile(
                name: "file2",
                fileName: "image2.png",
                contentType: "image/png",
                data: UIImage(named: "pic2")!.pngData()!,
                parameters: self.parameters
            )
        ]
    }

    public let fileName: String = UUID().uuidString
}
