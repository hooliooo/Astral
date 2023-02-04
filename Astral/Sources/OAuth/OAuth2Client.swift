//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Astral.Client
import enum Astral.HTTPMethod
import struct Astral.RequestBuilder
import class Foundation.JSONDecoder
import struct Foundation.URL
import class Foundation.URLResponse

/**
 An OAuth2Client is an abstraction over a Client with an easy to use API to communicate with RESTful APIs in an authenticated manner.
 */
public struct OAuth2Client {

  // MARK: Initializers
  /**
   Initializer for an OAuth2Client instance
   - parameters:
      - authorizationEndpoint: The authorization endpoint for authorization code requests
      - tokenEndpoint: The token endpoint for access token and refresh token requests
      - cliendId: The client id to be used in the authorization and token requests
      - store: The OAuth2TokenStore instance that reads/writes the token from the file system
   */
  public init(
    authorizationEndpoint: String,
    tokenEndpoint: String,
    clientId: String,
    store: OAuth2TokenStore = OAuth2TokenStore.shared
  ) {
    self.authorizationEndpoint = authorizationEndpoint
    self.tokenEndpoint = tokenEndpoint
    self.clientId = clientId
    self.store = store
  }


  // MARK: Properties
  /**
   The underlying Client instance to make http requests
   */
  private let client: Client = Client()

  /**
   The OAuth2 authorization endpoint
   */
  private let authorizationEndpoint: String

  /**
   The OAuth2 token endpoint
   */
  private let tokenEndpoint: String

  /**
   The OAuth2 clientId
   */
  private let clientId: String

  private let store: OAuth2TokenStore

  // MARK: Functions
  /**
   Queries the given OAuth2.0 authorization endpoint as a GET request with the necessary payload given the data
   from the PKCEAuthorization instance
   - parameters:
        - url: The URL of the OAuth2.0 token endpoint
        - authorization: The PKCEAuthorization instance containing data necessary for the http GET request
   */
  public func authorize(authorization: PKCEAuthorization) throws -> RequestBuilder {
    return try self.client.get(url: self.authorizationEndpoint).form(items: authorization.urlQueryItems)
  }

  /**
   Queries the given OAuth2.0 token url as a POST request with the necessary payload given the data
   from the CredentialsGrant instance
   - parameters:
        - url: The URL of the OAuth2.0 token endpoint
        - credentialGrant: The CredentialsGrant instance containing data necessary for the http POST request
   */
  public func token(credentialsGrant: CredentialsGrant) throws -> RequestBuilder {
    return try self.client.post(url: self.tokenEndpoint).form(items: credentialsGrant.urlQueryItems)
  }

  private func authenticate(request: OAuthGrantRequest) async throws {
    let decoder: JSONDecoder = JSONDecoder()
    decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
    switch request {
      case let .PKCE(redirectURI, scope):
        let codeVerifier: String = PKCEGenerator.generateCodeVerifier()
        guard let codeChallenge = PKCEGenerator.generateCodeChallenge(codeVerifier: codeVerifier) else {
          fatalError()
        }

        let authorization: PKCEAuthorization = PKCEAuthorization(
          clientId: self.clientId,
          scope: scope,
          codeChallenge: codeChallenge,
          redirectURI: redirectURI
        )

        let (_, response): (Any, URLResponse) = try await self
          .authorize(authorization: authorization)
          .send()

        await self.store.store(codeVerifier: codeVerifier)

      case .Grant(let grant):
        let (token, response): (OAuth2Token, URLResponse) = try await self
          .token(credentialsGrant: grant)
          .send(decoder: decoder)
        try await self.store.store(token: token)
    }
  }

  /**
   A convenience method to make a GET request to the URL
    - parameter url: The URL of the GET request
   */
  public func get(url: String) throws -> RequestBuilder {
    return try self.client.get(url: url)
  }

  /**
   A convenience method to make a DELETE request to the URL
    - parameter url: The URL of the DELETE request
   */
  public func delete(url: String) throws -> RequestBuilder {
    return try self.client.delete(url: url)
  }

  /**
   A convenience method to make a POST request to the URL
    - parameter url: The URL of the POST request
   */
  public func post(url: String) throws -> RequestBuilder {
    return try self.client.post(url: url)
  }

  /**
   A convenience method to make a PUT request to the URL
    - parameter url: The URL of the PUT request
   */
  public func put(url: String) throws -> RequestBuilder {
    return try self.client.put(url: url)
  }

}
