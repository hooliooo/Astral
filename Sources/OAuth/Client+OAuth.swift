//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class Foundation.URLResponse
import struct Astral.Client
import struct Astral.RequestBuilder
import struct Foundation.URLQueryItem

public extension Client {

  /**
   Queries the given OAuth2.0 token url as a POST request with the necessary payload given the data
   from the ResourceOwnerPasswordCredentialsGrant and ClientCredentials instances
   - parameters:
        - url: The URL of the OAuth2.0 token endpoint
        - credentialGrant: The ResourceOwnerPasswordCredentialsGrant instance containing data necessary for the http POST request
        - clientCredentials: The ClientCredentials instance containing data necessary for the http POST request
   */
  func passwordCredentials(
    url: String,
    credentialGrant: ResourceOwnerPasswordCredentialsGrant,
    clientCredentials: ClientCredentials
  ) throws -> RequestBuilder {
    let items: [URLQueryItem] = [
      ("password", \ResourceOwnerPasswordCredentialsGrant.password),
      ("username", \ResourceOwnerPasswordCredentialsGrant.username),
      ("grant_type", \ResourceOwnerPasswordCredentialsGrant.grantType),
      ("scope", \ResourceOwnerPasswordCredentialsGrant.scope)
    ].compactMap { (name: String, keyPath: PartialKeyPath<ResourceOwnerPasswordCredentialsGrant>) -> URLQueryItem? in
      URLQueryItem(name: name, value: credentialGrant[keyPath: keyPath] as? String)
    }

    return try self.post(url: url)
      .form(items: items)
      .basicAuthentication(username: clientCredentials.clientId, password: clientCredentials.clientSecret)
  }

//  func authenticate(
//    url: String,
//    credentialGrant: ResourceOwnerPasswordCredentialsGrant,
//    clientCredentials: ClientCredentials
//  ) async throws -> Client {
//    let (oauth2Response, response): (OAuth2Token, URLResponse) = try await self
//      .passwordCredentials(url: url, credentialGrant: credentialGrant, clientCredentials: clientCredentials)
//      .send()
//
//    // Save OAuth2
//
//    return self
//  }
  
}
