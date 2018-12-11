//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.FileManager
import struct Foundation.URL
import struct Foundation.Data

/**
The DSL used for FileManager extensions.
*/
public struct AstralFileManagerExtension {

    // MARK: Initializer
    /**
     AstralExtension is a struct used as a DSL for Astral specific extensions of existing Foundation classes/structs.
     - parameter base: The instance being managed to by the AstralExtension.
     */
    public init(base: FileManager) {
        self.base = base
    }

    /**
     The underlying FileManager
     */
    public let base: FileManager

}

public extension AstralFileManagerExtension {

    var cacheDirectory: URL {
        return self.base
            .urls(
                for: FileManager.SearchPathDirectory.cachesDirectory,
                in: FileManager.SearchPathDomainMask.userDomainMask
            )
            .first!
    }

    func fileURL(of request: MultiPartFormDataRequest) -> URL {
        return self.cacheDirectory.appendingPathComponent(request.fileName)
    }

    @discardableResult
    func writeAndCheck(data: Data, of request: MultiPartFormDataRequest) -> Bool {
        let fileURL: URL = self.fileURL(of: request)
        try? data.write(to: fileURL)
        return self.base.fileExists(atPath: fileURL.path)
    }

    func write(data: Data, of request: MultiPartFormDataRequest) throws {
        let fileURL: URL = self.fileURL(of: request)
        try data.write(to: fileURL)
    }

    @discardableResult
    func removeUploadedData(of request: MultiPartFormDataRequest) -> Bool {
        let fileURL: URL = self.cacheDirectory.appendingPathComponent(request.fileName)
        try? self.base.removeItem(at: fileURL)

        return self.base.fileExists(atPath: fileURL.path) == false
    }
}

public extension FileManager {

    /**
     The DSL instance.
     */
    var ast: AstralFileManagerExtension {
        return AstralFileManagerExtension(base: self)
    }

}
