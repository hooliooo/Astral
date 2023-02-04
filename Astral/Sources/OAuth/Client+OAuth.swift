//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.FileManager
import class Foundation.JSONEncoder
import class Foundation.JSONDecoder
import class Foundation.URLResponse
import struct Astral.Client
import struct Astral.RequestBuilder
import struct Foundation.Data
import struct Foundation.URL
import struct Foundation.URLQueryItem
import struct os.OSLogType

public extension Client {

  /**
   Queries the given OAuth2.0 token url as a POST request with the necessary payload given the data
   from the CredentialsGrant instance
   - parameters:
        - url: The URL of the OAuth2.0 token endpoint
        - credentialGrant: The CredentialsGrant instance containing data necessary for the http POST request
   */
  func oAuth2CredentialsGrant(url: String, credentialsGrant: CredentialsGrant) throws -> RequestBuilder {
    return try self.post(url: url).form(items: credentialsGrant.urlQueryItems)
  }

  func authenticate(url: String, credentialsGrant: CredentialsGrant) async throws -> Client {
    let decoder: JSONDecoder = JSONDecoder()
    decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
    let (token, response): (OAuth2Token, URLResponse) = try await self
      .oAuth2CredentialsGrant(url: url, credentialsGrant: credentialsGrant)
      .send(decoder: decoder)

//    self.logger.log(level: OSLogType.info, "Response Status Code: \(response.statusCode)")

    // Save OAuth2 in memory
    await OAuth2TokenStore.shared.storeInMemory(token: token)

    // Save OAuth2 to document directory
    Task.detached(priority: TaskPriority.background) { () -> Void in
      try await OAuth2TokenStore.shared.storeInFile(token: token)
    }

    return self
  }
  
}
