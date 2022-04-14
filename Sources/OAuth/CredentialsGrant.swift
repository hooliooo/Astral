//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import Foundation

public protocol CredentialsGrant {

  /**
   The grant type used for authentication
   */
  var grantType: String { get }

}
