//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation
import Astral

#if os(iOS) || os(watchOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

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
//    let parameters: Parameters = .none

    var headers: Set<Header> {

        return [
            Header(key: Header.Key.custom("Get-Request"), value: Header.Value.custom("Yes")),
            Header(key: Header.Key.contentType, value: Header.Value.mediaType(MediaType.multipartFormData(Astral.shared.boundary))),
            Header(key: Header.Key.custom("Connection"), value: Header.Value.custom("Keep-Alive"))
        ]
    }

    public var components: [MultiPartFormDataComponent] {

        let bundle: Bundle = Bundle(for: HeaderTests.self)

        let getData: (String) -> Data = { (imageName: String) -> Data in

            #if os(iOS) || os(watchOS) || os(tvOS)
                return UIImage(named: imageName, in: bundle, compatibleWith: nil)!.pngData()!
            #else
                let data = bundle.image(forResource: NSImage.Name(stringLiteral: imageName))!
                    .tiffRepresentation!
                let bitmap: NSBitmapImageRep = NSBitmapImageRep(data: data)!
                return bitmap.representation(using: .png, properties: [:])!
            #endif
        }

        let getURL: (String, String) -> URL = { (imageName: String, fileExtension: String) -> URL in
            return bundle.url(forResource: imageName, withExtension: fileExtension)! // swiftlint:disable:this force_unwrapping

        }
        
        return [
            MultiPartFormDataComponent(
                name: "file1",
                fileName: "image1.png",
                contentType: "image/png",
                file: MultiPartFormDataComponent.File.data(getData("pic1"))
            ),
            MultiPartFormDataComponent(
                name: "file2",
                fileName: "image2.png",
                contentType: "image/png",
                file: MultiPartFormDataComponent.File.url(getURL("pic2", "png"))
            ),
            MultiPartFormDataComponent(
                name: "file3",
                fileName: "image3.png",
                contentType: "image/png",
                file: MultiPartFormDataComponent.File.data(getData("pic3"))
            ),
        ]
    }

    public var fileName: String {
        return String(describing: Mirror(reflecting: self).subjectType)
    }
}
