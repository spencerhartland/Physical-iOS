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
        // Get auth code and ID token from authorization
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let authCodeData = appleIDCredential.authorizationCode,
              let identityTokenData = appleIDCredential.identityToken,
              let authCode = String(data: authCodeData, encoding: .utf8),
              let identityToken = String(data: identityTokenData, encoding: .utf8)
        else {
            completion(.failure(.invalidAuthorizationData))
            return
        }
        
        // Send request to Physical API for verification with Apple ID servers
        guard let request = try? AuthenticationRequest(using: authCode, identityToken: identityToken, grantType: .authorizationCode),
              let (data, response) = try? await URLSession.shared.data(for: request.urlRequest())
        else {
            completion(.failure(.couldNotCompleteRequest))
            return
        }
        
        // Check response status
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            
            // Decode the content
            do {
                // Try to decode as JSON
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("JSON Response:")
                    print(json)
                } else {
                    // Fallback if not JSON
                    let stringResponse = String(data: data, encoding: .utf8) ?? "Unable to decode response as string"
                    print("String Response:")
                    print(stringResponse)
                }
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
            }
            
            completion(.failure(.authenticationFailure))
            return
        }
        
        // Store user identifier in UserDefaults
        UserDefaults.standard.set(appleIDCredential.user, forKey: StorageKeys.userID)
        
        // Decode credentials
        guard let credentials = try? JSONDecoder().decode(Credentials.self, from: data) else {
            return completion(.failure(.decodingResponseFailure))
        }
        
        // Store credentials in Keychain
        do {
            try KeychainManager.storeCredentials(credentials)
        } catch {
            return completion(.failure(.keychainError))
        }
        
        completion(.success(()))
    }
}
