//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.URLQueryItem

/**
 Protocol representing grant types for OAuth2 
 */
public protocol OAuth2Grant {

  /**
   The grant type used for authentication
   */
  var grantType: String { get }

  /**
   The URLItems to be form-encoded in the http request
   */
  var urlQueryItems: [URLQueryItem] { get }

}
