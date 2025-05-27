//
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
import struct os.Logger

/**
 An OAuth2HTTPClient is an abstraction over a Client with an easy to use API to communicate with RESTful APIs in an authenticated manner.
 */
public actor OAuth2HTTPClient: Sendable {

  // MARK: Initializers
  /**
   Initializer for an OAuth2Client instance
   - parameters:
      - baseURL: The base URL of the authorization server
      - method: The method to be used when authenticating
   */
  public init(
    baseURL: String,
    method: AuthenticationMethod
  ) {
    let httpClient: HTTPClient = HTTPClient()
    self.httpClient = httpClient
    self.method = method
    self.store = OAuth2TokenStore(method: method)

    Task(priority: TaskPriority.userInitiated) { [weak self] in
      guard let self else { return }
      try await self.initializeConfiguration(baseURL: baseURL, httpClient: httpClient)
    }
  }

  // MARK: Properties
  /**
   The underlying Client instance to make http requests
   */
  private let httpClient: HTTPClient

  /**
   The OpenIDConnect Configuration of the authorization server the OAuth2HTTPClient is communicating with
   */
  private var configuration: OpenIDConnectConfiguration!

  /**
   The grant type to be used for authentication
   */
  public let method: AuthenticationMethod

  /**
   The OAuth2TokenStore instance used to read/write the OAuth2Token for authentication
   */
  private let store: OAuth2TokenStore

  /**
   The logger for the client
   */
  private static let logger: Logger = Logger(subsystem: "Astral+OAuth2", category: "OAuth2HTTPClient")

  // MARK: Functions

  private func initializeConfiguration(baseURL: String, httpClient: HTTPClient) async throws {
    self.configuration = try await OpenIDConnectConfiguration(baseURL: baseURL, httpClient: httpClient)
  }

  public func createAuthorizationURL(additonalURLQueryItems: [URLQueryItem] = []) throws -> URL {
    switch self.method {
      case let .authorizationCode(client, _, redirectURI, _, usePKCE):
        OAuth2HTTPClient.logger.debug("Creating authorization URL for authorization code flow")

        let authorization: AuthorizationCodeFlow = try AuthorizationCodeFlow(
          clientId: client.id,
          scope: "openid profile email",
          redirectURI: redirectURI,
          usePKCE: usePKCE
        )
        let queryItems: [URLQueryItem] = authorization.urlQueryItems

        if let pkce = authorization.pkce {
          let codeVerifier = pkce.codeVerifier
          // Store the code verifier for the authorization code flow request
          Task.detached(priority: TaskPriority.userInitiated) { [weak self] in
            guard let self else { return }
            await self.store.store(codeVerifier: codeVerifier)
          }
        }

        // Store the state for comparison when receiving the response from the authorization server
        let state: String = authorization.state
        Task.detached(priority: TaskPriority.userInitiated) { [weak self] in
          guard let self else { return }
          await self.store.store(state: state)
        }

        let url: URL = try self.httpClient.get(url: self.configuration.authorizationEndpoint)
          .query(items: queryItems + additonalURLQueryItems)
          .request
          .url!
        return url

      case .clientCredentials, .password: throw Error.invalidAuthenticationMethod(self.method)
    }
  }

  /**
   Extracts the code from the url and creates an AuthorizationCodeGrant or AuthorizationCodePKCEGrant to get an OAuth2Token
   - parameters:
        - url: The URL containing the authentication code for the Authorization Code Grant
   */
  public func createAuthorizationCodeGrant(from url: URL) async throws -> any OAuth2Grant {
    let urlComponents = URLComponents(string: url.absoluteString)
    guard
      let queryItems = urlComponents?.queryItems,
      let code = queryItems.first(where: { $0.name == "code" })?.value
    else {
      throw Error.missingAuthCode
    }

    // Compare the state received from the URL authorization server with the state that was stored
    guard let state = queryItems.first(where: { $0.name == "state"})?.value
    else { throw Error.missingState }
    let storedState = await self.store.state

    if storedState != state {
      throw Error.stateDoesNotMatch
    }

    switch self.method {
      case let .authorizationCode(client, _, redirectURI, _, _):
        return AuthorizationCodeGrant(
          client: client,
          code: code,
          redirectURI: redirectURI,
          codeVerifier: await self.store.codeVerifier
        )

      case .clientCredentials, .password: throw Error.invalidAuthenticationMethod(self.method)
    }
  }

  private func verifyAndStore(token: OAuth2Token) async throws {
    try await self.store.store(token: token)
  }

  /**
   Queries the given OAuth2.0 token url as a POST request with the necessary payload given the data
   from the OAuth2Grant instance
   - parameters:
        - credentialGrant: The CredentialsGrant instance containing data necessary for the http POST request
   */
  private func token(credentialsGrant: any OAuth2Grant) throws -> RequestBuilder {
    return try self.httpClient.post(url: self.configuration.tokenEndpoint).form(items: credentialsGrant.urlQueryItems)
  }

  private func authenticate(with grant: any OAuth2Grant) async throws {
    let decoder: JSONDecoder = JSONDecoder()
    decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
    let requestBuilder: RequestBuilder = try self.token(credentialsGrant: grant)
    let (token, _): (OAuth2Token, URLResponse) = try await requestBuilder.send(decoder: decoder)
    try await self.configuration.verifier.verify(token: token)

    OAuth2HTTPClient.logger.debug("Access Token: \(token.accessToken)")
    if let refreshToken = token.refreshToken {
      OAuth2HTTPClient.logger.debug("Refresh Token: \(refreshToken)")
    }
    if let idToken = token.idToken {
      OAuth2HTTPClient.logger.debug("Id Token: \(idToken)")
    }
    try await self.verifyAndStore(token: token)

    if grant is AuthorizationCodeGrant {
      await self.store.clear()
    }
  }

  public func refresh() async throws {
    let isAccessTokenExpired = await self.store.isAccessTokenExpired
    let isRefreshTokenExpired = await self.store.isRefreshTokenExpired
    if (isRefreshTokenExpired) {
      switch self.method {
        case let .authorizationCode(_, callbackScheme, _, delegate, _):
          let url: URL = try self.createAuthorizationURL()
          OAuth2HTTPClient.logger.log("Authorization URL: \(url)")
          let session = ASWebAuthenticationSession(
            url: url,
            callback: ASWebAuthenticationSession.Callback.customScheme(callbackScheme)
          ) { [weak self] (callbackURL: URL?, error: Swift.Error?) -> Void in
            guard let self else { return }
            if let callbackURL {
              OAuth2HTTPClient.logger.log("Callback URL: \(callbackURL)")
              Task {
                do {
                  let grant: any OAuth2Grant = try await self.createAuthorizationCodeGrant(from: callbackURL)
                  try await self.authenticate(with: grant)
                } catch Error.missingAuthCode {
                  OAuth2HTTPClient.logger.error("Missing auth code")
                } catch let error {
                  OAuth2HTTPClient.logger.error("Uncaught Error: \(error)")
                }
              }
            } else if let error {
              OAuth2HTTPClient.logger.error("Error: \(error)")
            }
          }

          session.presentationContextProvider = delegate

          Task.detached(priority: TaskPriority.userInitiated) { @MainActor in
            session.start()
          }

        case let .clientCredentials(credentials):
          let grant: ClientCredentialsGrant = ClientCredentialsGrant(
            credentials: credentials,
            scope: "openid profile email"
          )
          try await self.authenticate(with: grant)

        case let .password(credentials, username, password):
          let grant: ResourceOwnerPasswordCredentialsGrant = ResourceOwnerPasswordCredentialsGrant(
            username: username,
            password: password,
            scope: "openid profile email",
            credentials: credentials
          )
          try await self.authenticate(with: grant)
      }
    } else if (isAccessTokenExpired) {
      let refreshToken = await self.store.token!.refreshToken!
      let grant: RefreshGrant = RefreshGrant(clientId: self.method.clientId, refreshToken: refreshToken)
      let (token, _): (OAuth2Token, URLResponse) = try await self.token(credentialsGrant: grant).send()
      try await self.verifyAndStore(token: token)
    }
  }

  /**
   Creates an authenticated request to the url with the specified http method
   - parameters:
   - url: The URL of the request
   - method: The http method of the request
   */
  public func request(url: String, method: HTTPMethod) async throws -> RequestBuilder {
    try await self.refresh()
    return try self.httpClient.request(url: url, method: method).bearerAuthentication(token: await self.store.token!.accessToken)
  }

  /**
   A convenience method to make an authenticated GET request to the URL
    - parameter url: The URL of the GET request
   */
  public func get(url: String) async throws -> RequestBuilder {
    return try await self.request(url: url, method: HTTPMethod.get)
  }

  /**
   A convenience method to make an authenticated DELETE request to the URL
    - parameter url: The URL of the DELETE request
   */
  public func delete(url: String) async throws -> RequestBuilder {
    return try await self.request(url: url, method: HTTPMethod.delete)
  }

  /**
   A convenience method to make an authenticated POST request to the URL
    - parameter url: The URL of the POST request
   */
  public func post(url: String) async throws -> RequestBuilder {
    return try await self.request(url: url, method: HTTPMethod.post)
  }

  /**
   A convenience method to make an authenticated PUT request to the URL
    - parameter url: The URL of the PUT request
   */
  public func put(url: String) async throws -> RequestBuilder {
    return try await self.request(url: url, method: HTTPMethod.put)
  }

}

public extension OAuth2HTTPClient {
  enum Error: Swift.Error {
    case invalidAuthenticationMethod(AuthenticationMethod)
    case invalidGrant(grant: any OAuth2Grant)
    case missingAuthCode
    case missingState
    case stateDoesNotMatch
  }
}

