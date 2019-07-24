//
//  URLReqeustCachePolicy+Astral.swift
//  Astral
//
//  Created by Julio Miguel Alorro on 14.07.19.
//

import struct Foundation.URLRequest

/**
 The DSL used for URLRequest.CachePolicy extensions.
 */
public struct AstralURLRequestCachePolicyExtension {

    // MARK: Initializer
    /**
     AstralExtension is a struct used as a DSL for Astral specific extensions of existing Foundation classes/structs.
     - parameter base: The instance being managed to by the AstralExtension.
     */
    public init(base: URLRequest.CachePolicy) {
        self.base = base
    }

    /**
     The underlying URLRequest.CachePolicy
     */
    public let base: URLRequest.CachePolicy

}

public extension AstralURLRequestCachePolicyExtension {

    /**
     The string value of the URLRequest.CachePolicy.
     */
    var stringValue: String {
        switch self.base {
            case .reloadIgnoringLocalAndRemoteCacheData:
                return "reloadIgnoringLocalAndRemoteCacheData"
            case .reloadIgnoringLocalCacheData:
                return "reloadIgnoringLocalCacheData"
            case .reloadRevalidatingCacheData:
                return "reloadRevalidatingCacheData"
            case .returnCacheDataDontLoad:
                return "returnCacheDataDontLoad"
            case .returnCacheDataElseLoad:
                return "returnCacheDataElseLoad"
            case .useProtocolCachePolicy:
                return "useProtocolCachePolicy"
            @unknown default:
                return "New case. No string value yet."
        }

    }

}

public extension URLRequest.CachePolicy {

    /**
     The DSL instance.
     */
    var ast: AstralURLRequestCachePolicyExtension {
        return AstralURLRequestCachePolicyExtension(base: self)
    }

}
