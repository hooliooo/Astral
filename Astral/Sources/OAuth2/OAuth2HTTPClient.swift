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
    method: AuthenticationMethod,
    appName: String,
  ) {
    let httpClient: HTTPClient = HTTPClient()
    self.httpClient = httpClient
    self.method = method
    self.store = OAuth2TokenStore(method: method)
    self.dPoPManager = DPoPManager(appName: appName)

    Task(priority: TaskPriority.userInitiated) { [weak self] in
      guard let self else { return }
      try await self.initializeConfiguration(baseURL: baseURL, httpClient: httpClient)
    }

    Task(priority: TaskPriority.userInitiated) { [weak self] in
      guard let self else { return }
      let _ = try await self.store.readFromFile()
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
   
   */
  private let dPoPManager: DPoPManager

  /**
   The logger for the client
   */
  private static let logger: Logger = Logger(subsystem: "Astral+OAuth2", category: "OAuth2HTTPClient")

  // MARK: Functions

  private func initializeConfiguration(baseURL: String, httpClient: HTTPClient) async throws {
    self.configuration = try await OpenIDConnectConfiguration(baseURL: baseURL, httpClient: httpClient)
  }

  private func generateDPoPProof(url: String, httpMethod: HTTPMethod, accessToken: String? = nil) throws -> String {
    let privateKey = try dPoPManager.retrieveOrCreateKey()
    return try DPoPProofGenerator.generate(
      privateKey: privateKey,
      parameters: DPoPProofGenerator.Parameters(
        httpMethod: httpMethod.stringValue,
        url: url,
        accessToken: accessToken,
        nonce: nil
      )
    )
  }

  public func createAuthorizationURL(additonalURLQueryItems: [URLQueryItem] = [], scope: String = "openid profile email") throws -> URL {
    switch self.method {
      case let .authorizationCode(client, _, redirectURI, _, usePKCE, useDPoP):
        OAuth2HTTPClient.logger.debug("Creating authorization URL for authorization code flow")

        let dPoPThumbprint: String? = try useDPoP
          ? DPoPProofGenerator.generateJWKThumbprint(try self.dPoPManager.retrieveOrCreateKey().publicKey)
          : nil
        
        let authorization: AuthorizationCodeFlow = try AuthorizationCodeFlow(
          clientId: client.id,
          scope: scope,
          redirectURI: redirectURI,
          usePKCE: usePKCE,
          dPoPThumbprint: dPoPThumbprint
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
      case let .authorizationCode(client, _, redirectURI, _, _, _):
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
    let builder: RequestBuilder = try self.httpClient
      .post(url: self.configuration.tokenEndpoint)
      .form(items: credentialsGrant.urlQueryItems)

    if self.method.useDPoP {
      let proof: String = try generateDPoPProof(url: self.configuration.tokenEndpoint, httpMethod: HTTPMethod.post)
      return builder.headers(headers: [Header(key: Header.Key.custom("DPoP"), value: Header.Value.custom(proof))])
    }

    return builder
  }

  private func authenticate(with grant: any OAuth2Grant) async throws {
    let decoder: JSONDecoder = JSONDecoder()
    decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
    let requestBuilder: RequestBuilder = try self.token(credentialsGrant: grant)
    let (token, _): (OAuth2Token, URLResponse) = try await requestBuilder.send(decoder: decoder)
//    let (token, response): (String, URLResponse) = try await requestBuilder.send()
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

  public func refresh(scope: String = "openid profile email") async throws {
    let isAccessTokenExpired = await self.store.isAccessTokenExpired
    let isRefreshTokenExpired = await self.store.isRefreshTokenExpired
    if isRefreshTokenExpired {
      switch self.method {
        case let .authorizationCode(_, callbackScheme, _, delegate, _, useDPoP):
          let url: URL = try self.createAuthorizationURL(scope: scope)
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

        case let .clientCredentials(credentials, useDPoP):
          let grant: ClientCredentialsGrant = ClientCredentialsGrant(
            credentials: credentials,
            scope: scope
          )
          try await self.authenticate(with: grant)

        case let .password(credentials, username, password, useDPoP):
          let grant: ResourceOwnerPasswordCredentialsGrant = ResourceOwnerPasswordCredentialsGrant(
            username: username,
            password: password,
            scope: scope,
            credentials: credentials
          )
          try await self.authenticate(with: grant)
      }
    } else if isAccessTokenExpired {
      let refreshToken = await self.store.token!.refreshToken!
      let grant: RefreshGrant = RefreshGrant(clientId: self.method.clientId, refreshToken: refreshToken)
      let (token, _): (OAuth2Token, URLResponse) = try await self.token(credentialsGrant: grant).send()
      try await self.verifyAndStore(token: token)
    }
  }

  public func logout() async throws {
    let hasToken: Bool = await self.store.hasToken
    guard hasToken else { return }
    guard let token = await self.store.token else { return }

    guard case let .authorizationCode(client, _, _, _, _, _) = method else {
      return
    }

    if let refreshToken = token.refreshToken {
      let (revokeBody, revokeResponse): (String, URLResponse) = try await self.httpClient
        .post(url: self.configuration.revocationEndpoint)
        .form(items: [
          URLQueryItem(name: "client_id", value: client.id),
          URLQueryItem(name: "token", value: refreshToken),
          URLQueryItem(name: "token_type_hint", value: "refresh_token")
        ])
        .send()
      OAuth2HTTPClient.logger.debug("Revocation Response Body: \(revokeBody)")
      OAuth2HTTPClient.logger.debug("Revocation Response: \(revokeResponse)")
    }

    try await self.store.removeToken()
  }

  /**
   Creates an authenticated request to the url with the specified http method
   - parameters:
   - url: The URL of the request
   - method: The http method of the request
   */
  public func request(url: String, method: HTTPMethod) async throws -> RequestBuilder {
    try await self.refresh()
    let builder = try self.httpClient.request(url: url, method: method)
    if self.method.useDPoP {
      let accessToken = await self.store.token!.accessToken
      let proof = try self.generateDPoPProof(url: url, httpMethod: method, accessToken: accessToken)
      return builder.dPoP(token: accessToken, proof: proof)
    } else {
      return builder.bearerAuthentication(token: await self.store.token!.accessToken)
    }
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

