//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import struct Astral.HTTPClient
import enum Astral.HTTPMethod
import struct Astral.RequestBuilder
import class Foundation.JSONDecoder
import struct Foundation.URL
import struct Foundation.URLComponents
import struct Foundation.URLQueryItem
import class Foundation.URLResponse

/**
 An OAuth2HTTPClient is an abstraction over a Client with an easy to use API to communicate with RESTful APIs in an authenticated manner.
 */
public struct OAuth2HTTPClient {

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
  private let httpClient: HTTPClient = HTTPClient()

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

  /**
   The OAuth2TokenStore instance used to read/write the OAuth2Token for authentication
   */
  private let store: OAuth2TokenStore

  // MARK: Functions
  /**
   Builds a complete PKCE authorization request URL with the given redirect_uri
   - parameters:
        - redirectURI: The redirect uri where the authorization response will be sent
   */
  public func createAuthorizationURL(
    redirectURI: String,
    additionalURLQueryItems: [URLQueryItem] = []
  ) throws -> URL {
    let codeVerifier = PKCEGenerator.generateCodeVerifier()
    guard let codeChallenge = PKCEGenerator.generateCodeChallenge(codeVerifier: codeVerifier) else {
      fatalError()
    }

    let authorization: PKCEAuthorization = PKCEAuthorization(
      clientId: self.clientId,
      scope: "openid profile email",
      codeChallenge: codeChallenge,
      redirectURI: redirectURI
    )
    let url: URL? = try self.httpClient.get(url: self.authorizationEndpoint)
      .query(items: authorization.urlQueryItems + additionalURLQueryItems)
      .request
      .url
    guard let url else {
      fatalError()
    }

    // Store the code verifier for the authorization code flow request
    Task.detached(priority: TaskPriority.userInitiated) {
      await self.store.store(codeVerifier: codeVerifier)
    }

    return url
  }

  /**
   Extracts the code from the authorization response and creates an AuthorizationCodePKCEGrant to get an OAuth2Token
   - parameters:
        - url: The URL containing the authentication code for the Authorization Code Grant
        - redirectURI: The redirect uri where the token response will be sent
   */
  public func createAuthorizationCodeGrant(
    from url: URL,
    redirectURI: String
  ) async throws -> AuthorizationCodePKCEGrant {
    let urlComponents = URLComponents(string: url.absoluteString)
    guard
      let queryItems = urlComponents?.queryItems,
      let code = queryItems.first(where: { $0.name == "code" })?.value,
      let codeVerifier = await self.store.codeVerifier
    else {
      fatalError()
    }

    return AuthorizationCodePKCEGrant(
      clientId: self.clientId,
      code: code,
      codeVerifier: codeVerifier,
      redirectURI: redirectURI
    )
  }

  public func implicitGrantAuthorizationURL(redirectURI: String) throws -> URL {
    let grant: ImplicitGrant = ImplicitGrant(clientId: self.clientId, redirectURI: redirectURI)
    let url: URL? = try self.httpClient
      .get(url: self.authorizationEndpoint)
      .query(items: grant.urlQueryItems)
      .request
      .url
    guard let url else {
      fatalError()
    }
    return url
  }

  /**
   Queries the given OAuth2.0 token url as a POST request with the necessary payload given the data
   from the OAuth2Grant instance
   - parameters:
        - url: The URL of the OAuth2.0 token endpoint
        - credentialGrant: The CredentialsGrant instance containing data necessary for the http POST request
   */
  public func token(credentialsGrant: OAuth2Grant) throws -> RequestBuilder {
    return try self.httpClient.post(url: self.tokenEndpoint).form(items: credentialsGrant.urlQueryItems)
  }

  public func authenticate(with grant: OAuth2Grant) async throws {
    let decoder: JSONDecoder = JSONDecoder()
    decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
    let (token, response): (String, URLResponse) = try await self
      .token(credentialsGrant: grant)
      .send()
    print(token)
//    try await self.store.store(token: token)
  }

  /**
   A convenience method to make a GET request to the URL
    - parameter url: The URL of the GET request
   */
  public func get(url: String) throws -> RequestBuilder {
    return try self.httpClient.get(url: url)
  }

  /**
   A convenience method to make a DELETE request to the URL
    - parameter url: The URL of the DELETE request
   */
  public func delete(url: String) throws -> RequestBuilder {
    return try self.httpClient.delete(url: url)
  }

  /**
   A convenience method to make a POST request to the URL
    - parameter url: The URL of the POST request
   */
  public func post(url: String) throws -> RequestBuilder {
    return try self.httpClient.post(url: url)
  }

  /**
   A convenience method to make a PUT request to the URL
    - parameter url: The URL of the PUT request
   */
  public func put(url: String) throws -> RequestBuilder {
    return try self.httpClient.put(url: url)
  }

}
