//
//  AuthenticationManager.swift
//  Physical
//
//  Created by Spencer Hartland on 10/18/23.
//

import Foundation
import AuthenticationServices
import Security

/// Manages user authentication and session.
final class AuthenticationManager {
    private let authServer = "physical.spencerhartland.com"
    
    static let shared = AuthenticationManager()
    
    /// Sends an authentication request to the `/auth` endpoint.
    ///
    /// Creates an `AuthenticationRequest` containing the `authorizationCode`
    /// and `identityToken` extracted from the `ASAuthorization` instance returned by Sign In With Apple.
    /// Sends the request to the `/auth` endpoint.
    ///
    /// - Parameters:
    ///     - authorization: The `ASAuthorization` instance obtained from Sign In With Apple after successful user authorization.
    ///     - completion: This closure will be executed upon failure or completion of auhentication.
    ///
    /// ## Usage
    /// ```swift
    /// await AuthenticationManager.shared.authenticate(with: authorization) { result in
    ///     switch result {
    ///     case .success:
    ///         // ...
    ///     case .failure(let error):
    ///         // ...
    ///     }
    /// }
    /// ```
    func authenticate(with authorization: ASAuthorization, completion: (Result<Void, AuthenticationError>) -> Void) async {
        // Get auth code from authorization
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let authCodeData = credential.authorizationCode,
              let identityTokenData = credential.identityToken,
              let authCode = String(data: authCodeData, encoding: .utf8),
              let identityToken = String(data: identityTokenData, encoding: .utf8)
        else {
            completion(.failure(AuthenticationError.invalidAuthorizationData))
            return
        }
        
        // Send request to Physical API for verification with Apple ID servers
        guard let request = try? AuthenticationRequest(using: authCode, identityToken: identityToken, grantType: .authorizationCode),
              let (_, response) = try? await URLSession.shared.data(for: request.urlRequest())
        else {
            completion(.failure(AuthenticationError.couldNotCompleteRequest))
            return
        }
        
        // Check response status
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            completion(.failure(AuthenticationError.authenticationFailure))
            return
        }
        
        // Store user identifier in UserDefaults
        UserDefaults.standard.set(credential.user, forKey: StorageKeys.userID)
        
        completion(.success(()))
    }
    
    /// Stores user credentials in the system keychain.
    ///
    /// - Parameter credentials: The `Credentials` object containing the user credentials to store.
    ///
    /// - Throws: `KeychainError.unhandledError(status:)` if the operation is unsuccessful.
    func addCredentialsToKeychain(_ credentials: Credentials) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: credentials.username,
                                    kSecAttrServer as String: authServer,
                                    kSecValueData as String: credentials.refreshToken.data(using: .utf8)!]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
    
    /// Loads user credentials stored in the system keychain.
    ///
    /// - Throws: `KeychainError.keychainItemNotFound` if the credentials are not found in the system keychain.\
    /// `KeychainError.unhandledError(status:)` if the operation fails for any other reason.
    ///
    /// - Returns: The current user's credentials.
    func loadCredentialsFromKeychain() throws -> Credentials {
        // Create the query
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: authServer,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        
        // Search the keychain
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.keychainItemNotFound }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        
        // Extract the token from the result
        guard let existingItem = item as? [String: Any],
              let tokenData = existingItem[kSecValueData as String] as? Data,
              let token = String(data: tokenData, encoding: .utf8),
              let username = existingItem[kSecAttrAccount as String] as? String
        else {
            throw KeychainError.unexpectedPasswordData
        }
        
        return Credentials(username: username, refreshToken: token)
    }
}
