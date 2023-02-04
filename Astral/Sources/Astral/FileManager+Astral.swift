//
//  Astral
//  Copyright (c) Julio Miguel Alorro
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

  /**
   The URL to the caches directory in the user domain mask.
   */
  var cacheDirectory: URL {
    return self.base
      .urls(
        for: FileManager.SearchPathDirectory.cachesDirectory,
        in: FileManager.SearchPathDomainMask.userDomainMask
      )
      .first! // swiftlint:disable:this force_unwrapping
  }

  /**
   The URL to the caches directory in the user domain mask.
   */
  var documentDirectory: URL {
    return self.base
      .urls(
        for: FileManager.SearchPathDirectory.documentDirectory,
        in: FileManager.SearchPathDomainMask.userDomainMask
      )
      .first! // swiftlint:disable:this force_unwrapping
  }

  /**
   Creates a URL leading to the caches directory with the MultiPartFormDataRequest fileName as a path component.
   */
  func fileURL(with fileName: String) -> URL {
    return self.cacheDirectory.appendingPathComponent(fileName)
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
