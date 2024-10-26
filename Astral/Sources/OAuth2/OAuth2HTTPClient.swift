//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import class AuthenticationServices.ASWebAuthenticationSession
import class Foundation.JSONDecoder
import class Foundation.NSObject
import class Foundation.URLResponse
import enum Astral.HTTPMethod
import struct Astral.Header
import struct Astral.HTTPClient
import struct Astral.RequestBuilder
import struct Foundation.URL
import struct Foundation.URLComponents
import struct Foundation.URLQueryItem
import struct Foundation.URLRequest

/**
 An OAuth2HTTPClient is an abstraction over a Client with an easy to use API to communicate with RESTful APIs in an authenticated manner.
 */
public final class OAuth2HTTPClient: NSObject, Sendable {

  // MARK: Initializers
  /**
   Initializer for an OAuth2Client instance
   - parameters:
      - authorizationEndpoint: The authorization endpoint for authorization code requests
      - tokenEndpoint: The token endpoint for access token and refresh token requests
      - authenticationMethod: The grant type to be used when authenticating
   */
  public init(
    authorizationEndpoint: String,
    tokenEndpoint: String,
    grantType: AuthenticationMethod
  ) {
    self.authorizationEndpoint = authorizationEndpoint
    self.tokenEndpoint = tokenEndpoint
    self.authenticationMethod = grantType
    self.store = OAuth2TokenStore(grantType: grantType)
    super.init()
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
   The grant type to be used for authentication
   */
  public let authenticationMethod: AuthenticationMethod

  /**
   The OAuth2TokenStore instance used to read/write the OAuth2Token for authentication
   */
  private let store: OAuth2TokenStore

  // MARK: Functions
  public func createAuthorizationURL(additonalURLQueryItems: [URLQueryItem] = []) throws -> URL {
    switch self.authenticationMethod {
      case let .authorizationCode(clientId, clientSecret, callbackScheme, redirectURI, _, usePKCE):
        let queryItems: [URLQueryItem]
        if usePKCE {
          let codeVerifier = PKCEGenerator.generateCodeVerifier()
          guard let codeChallenge = PKCEGenerator.generateCodeChallenge(codeVerifier: codeVerifier) else {
            fatalError()
          }
          let authorization: AuthorizationCodeWithPKCE = AuthorizationCodeWithPKCE(
            clientId: clientId,
            scope: "openid profile email",
            codeChallenge: codeChallenge,
            redirectURI: redirectURI
          )

          // Store the code verifier for the authorization code flow request
          Task.detached(priority: TaskPriority.userInitiated) {
            await self.store.store(codeVerifier: codeVerifier)
          }

          queryItems = authorization.urlQueryItems
        } else {
          let authorization: AuthorizationCodeFlow = AuthorizationCodeFlow(
            clientId: clientId,
            scope: "openid profile email",
            redirectURI: redirectURI
          )
          queryItems = authorization.urlQueryItems
        }

        let url: URL? = try self.httpClient.get(url: self.authorizationEndpoint)
          .query(items: queryItems + additonalURLQueryItems)
          .request
          .url
        guard let url else { fatalError() }
        return url

      case let .clientCredentials(clientId, clientSecret): fatalError()
    }
  }

  /**
   Extracts the code from the url and creates an AuthorizationCodeGrant or AuthorizationCodePKCEGrant to get an OAuth2Token
   - parameters:
        - url: The URL containing the authentication code for the Authorization Code Grant
   */
  public func createAuthorizationCodeGrant(from url: URL) async throws -> OAuth2Grant {
    let urlComponents = URLComponents(string: url.absoluteString)
    guard
      let queryItems = urlComponents?.queryItems,
      let code = queryItems.first(where: { $0.name == "code" })?.value
    else {
      fatalError()
    }

    switch self.authenticationMethod {
      case let .authorizationCode(clientId, clientSecret, _, redirectURI, _, usePKCE):
        if usePKCE {
          guard let codeVerifier = await self.store.codeVerifier else { fatalError() }
          return AuthorizationCodePKCEGrant(
            clientId: clientId,
            code: code,
            codeVerifier: codeVerifier,
            redirectURI: redirectURI
          )
        } else {
          return AuthorizationCodeGrant(
            clientId: clientId,
            clientSecret: clientSecret,
            code: code,
            redirectURI: redirectURI
          )
        }

      case .clientCredentials: fatalError()
    }
  }

  /**
   Queries the given OAuth2.0 token url as a POST request with the necessary payload given the data
   from the OAuth2Grant instance
   - parameters:
        - url: The URL of the OAuth2.0 token endpoint
        - credentialGrant: The CredentialsGrant instance containing data necessary for the http POST request
   */
  private func token(credentialsGrant: OAuth2Grant) throws -> RequestBuilder {
    return try self.httpClient.post(url: self.tokenEndpoint).form(items: credentialsGrant.urlQueryItems)
  }

  private func authenticate(with grant: OAuth2Grant) async throws {
    let decoder: JSONDecoder = JSONDecoder()
    decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
    let requestBuilder: RequestBuilder = try self.token(credentialsGrant: grant)
    let request: URLRequest = requestBuilder.request
    let formParams: [String.SubSequence] = String(data: request.httpBody!, encoding: .utf8)!.split(separator: "&")

    let (token, response): (OAuth2Token, URLResponse) = try await requestBuilder.send()
    try await self.store.store(token: token)
  }

  public func refresh() async throws {
    let isAccessTokenExpired = await self.store.isAccessTokenExpired
    let isRefreshTokenExpired = await self.store.isRefreshTokenExpired

    if (isRefreshTokenExpired) {
      switch self.authenticationMethod {
        case let .authorizationCode(_, _, callbackScheme, _, delegate, _):
          Task { @MainActor in
            let url = try! self.createAuthorizationURL()
            let session = ASWebAuthenticationSession(
              url: url,
              callbackURLScheme: callbackScheme
            ) { (callbackURL: URL?, error: Error?) -> Void in
              if let callbackURL {
                Task {
                  let grant: OAuth2Grant = try await self.createAuthorizationCodeGrant(from: callbackURL)
                  try await self.authenticate(with: grant)
                }
              }
            }
            session.presentationContextProvider = delegate
            session.prefersEphemeralWebBrowserSession = true
            session.start()
          }

        case let .clientCredentials(clientId, clientSecret):
          let grant: ClientCredentialsGrant = ClientCredentialsGrant(
            credentials: ClientCredentials(clientId: clientId, clientSecret: clientSecret),
            scope: "openid profile email"
          )
          try await self.authenticate(with: grant)
      }
    } else if (isAccessTokenExpired) {
      let refreshToken = await self.store.token!.refreshToken!
      let grant: RefreshGrant = RefreshGrant(clientId: self.authenticationMethod.clientId, refreshToken: refreshToken)
      let (token, response): (OAuth2Token, URLResponse) = try await self.token(credentialsGrant: grant).send()
      try await self.store.store(token: token)
    }
  }

  /**
   A convenience method to make a GET request to the URL
    - parameter url: The URL of the GET request
   */
  public func get(url: String) async throws -> RequestBuilder {
    try await self.refresh()
    return try self.httpClient.get(url: url).headers(
      headers: [
        Header(key: Header.Key.authorization, value: Header.Value.bearerToken(await store.token!.accessToken))
      ]
    )
  }

  /**
   A convenience method to make a DELETE request to the URL
    - parameter url: The URL of the DELETE request
   */
  public func delete(url: String) async throws -> RequestBuilder {
    try await self.refresh()
    return try self.httpClient.delete(url: url).headers(
      headers: [
        Header(key: Header.Key.authorization, value: Header.Value.bearerToken(await store.token!.accessToken))
      ]
    )
  }

  /**
   A convenience method to make a POST request to the URL
    - parameter url: The URL of the POST request
   */
  public func post(url: String) async throws -> RequestBuilder {
    try await self.refresh()
    return try self.httpClient.post(url: url).headers(
      headers: [
        Header(key: Header.Key.authorization, value: Header.Value.bearerToken(await store.token!.accessToken))
      ]
    )
  }

  /**
   A convenience method to make a PUT request to the URL
    - parameter url: The URL of the PUT request
   */
  public func put(url: String) async throws -> RequestBuilder {
    try await self.refresh()
    return try self.httpClient.put(url: url).headers(
      headers: [
        Header(key: Header.Key.authorization, value: Header.Value.bearerToken(await store.token!.accessToken))
      ]
    )
  }

}

