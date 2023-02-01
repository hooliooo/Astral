//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Foundation.URLQueryItem

public protocol CredentialsGrant {

  /**
   The grant type used for authentication
   */
  var grantType: String { get }

  /**
   The URLItems to be form-encoded in the http request
   */
  var urlQueryItems: [URLQueryItem] { get }

}
