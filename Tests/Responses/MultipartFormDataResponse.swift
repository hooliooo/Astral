//
//  MultipartFormDataResponse.swift
//  AstralTests
//
//  Created by Julio Alorro on 2/3/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

struct MultipartFormDataResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case form
        case headers
        case url
        case files
    }

    struct DynamicKey: CodingKey {

        init?(stringValue: String) {
            self._stringValue = stringValue
        }

        private let _stringValue: String

        var stringValue: String { return self._stringValue }

        init?(intValue: Int) { return nil }

        var intValue: Int? { return nil }

    }

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<MultipartFormDataResponse.CodingKeys> = try decoder.container(
            keyedBy: MultipartFormDataResponse.CodingKeys.self
        )

        self.form = try container.decode(BinData.self, forKey: MultipartFormDataResponse.CodingKeys.form)
        self.headers = try container.decode(BinHeaders.self, forKey: MultipartFormDataResponse.CodingKeys.headers)
        self.files = try container.nestedContainer(
                keyedBy: MultipartFormDataResponse.DynamicKey.self,
                forKey: MultipartFormDataResponse.CodingKeys.files
            )
            .allKeys
            .map { $0.stringValue }

        self.url = try container.decode(URL.self, forKey: MultipartFormDataResponse.CodingKeys.url)
    }

    public let form: BinData
    public let headers: BinHeaders
    public let files: [String]
    public let url: URL

}
