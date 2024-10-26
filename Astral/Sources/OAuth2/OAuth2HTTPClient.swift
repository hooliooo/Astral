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
public struct OAuth2HTTPClient: Sendable {

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

  /**
   The logger for the client
   */
  public let logger: Logger = Logger(subsystem: "Astral+OAuth2", category: "OAuth2HTTPClient")

  // MARK: Functions
  public func createAuthorizationURL(additonalURLQueryItems: [URLQueryItem] = []) throws -> URL {
    switch self.authenticationMethod {
      case let .authorizationCode(client, _, redirectURI, _, usePKCE):
        logger.debug("Creating authorization URL for authorization code flow")

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
          Task.detached(priority: TaskPriority.userInitiated) {
            await self.store.store(codeVerifier: codeVerifier)
          }
        }

        let url: URL? = try self.httpClient.get(url: self.authorizationEndpoint)
          .query(items: queryItems + additonalURLQueryItems)
          .request
          .url
        guard let url else { throw Error.invalidURL }
        return url

      case .clientCredentials, .password: throw Error.invalidAuthenticationMethod(self.authenticationMethod)
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

    switch self.authenticationMethod {
      case let .authorizationCode(client, _, redirectURI, _, _):
        return AuthorizationCodeGrant(
          client: client,
          code: code,
          redirectURI: redirectURI,
          codeVerifier: await self.store.codeVerifier
        )

      case .clientCredentials, .password: throw Error.invalidAuthenticationMethod(self.authenticationMethod)
    }
  }

  /**
   Queries the given OAuth2.0 token url as a POST request with the necessary payload given the data
   from the OAuth2Grant instance
   - parameters:
        - credentialGrant: The CredentialsGrant instance containing data necessary for the http POST request
   */
  private func token(credentialsGrant: any OAuth2Grant) throws -> RequestBuilder {
    return try self.httpClient.post(url: self.tokenEndpoint).form(items: credentialsGrant.urlQueryItems)
  }

  private func authenticate(with grant: any OAuth2Grant) async throws {
    let decoder: JSONDecoder = JSONDecoder()
    decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
    let requestBuilder: RequestBuilder = try self.token(credentialsGrant: grant)
    let (token, _): (OAuth2Token, URLResponse) = try await requestBuilder.send()
    try await self.store.store(token: token)
  }

  public func refresh() async throws {
    let isAccessTokenExpired = await self.store.isAccessTokenExpired
    let isRefreshTokenExpired = await self.store.isRefreshTokenExpired

    if (isRefreshTokenExpired) {
      switch self.authenticationMethod {
        case let .authorizationCode(_, callbackScheme, _, delegate, _):
          let url: URL = try self.createAuthorizationURL()

          Task { @MainActor in
            let session = ASWebAuthenticationSession(
              url: url,
              callback: ASWebAuthenticationSession.Callback.customScheme(callbackScheme)
            ) { (callbackURL: URL?, error: Swift.Error?) -> Void in
              if let callbackURL {
                Task {
                  do {
                    let grant: any OAuth2Grant = try await self.createAuthorizationCodeGrant(from: callbackURL)
                    try await self.authenticate(with: grant)
                  } catch Error.missingAuthCode {
                    self.logger.error("Missing auth code")
                  } catch let error {
                    self.logger.error("Uncaught Error: \(error)")
                  }
                }
              } else if let error {
                self.logger.error("Error: \(error)")
              }
            }
            session.presentationContextProvider = delegate
            session.prefersEphemeralWebBrowserSession = true
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
      let grant: RefreshGrant = RefreshGrant(clientId: self.authenticationMethod.clientId, refreshToken: refreshToken)
      let (token, _): (OAuth2Token, URLResponse) = try await self.token(credentialsGrant: grant).send()
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

public extension OAuth2HTTPClient {
  enum Error: Swift.Error {
    case invalidURL
    case invalidAuthenticationMethod(AuthenticationMethod)
    case invalidGrant(grant: any OAuth2Grant)
    case missingAuthCode
  }
}
