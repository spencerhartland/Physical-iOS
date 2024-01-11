//
//  UserAccountManager.swift
//  Physical
//
//  Created by Spencer Hartland on 12/21/23.
//

import SwiftUI
import Foundation

final class UserAccountManager {
    static let shared = UserAccountManager()
    
    private let userIDKey = "userID"
    
    @AppStorage(StorageKeys.userID) private var userID: String = ""
    
    /// Creates a user account with information about the specified `User`.
    func createAccount(for user: User) async throws {
        let request = try UserAccountCreationRequest(user)
        let (_, response) = try await URLSession.shared.data(for: request.urlRequest())
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw UserAccountError.creationRequestError
        }
        
        return
    }
    
    /// Fetches the username of the user with the specified user ID.
    func fetchUserID(for username: String) async throws -> String {
        let request = try UserIDFetchRequest(for: userID)
        let (data, response) = try await URLSession.shared.data(for: request.urlRequest())
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw UserAccountError.fetchRequestError
        }
        
        let userIDResponse = try JSONDecoder().decode(UserIDResponse.self, from: data)
        return userIDResponse.userID
    }
    
    /// Fetches the account of the currently authenticated user using the stored user ID.
    func fetchAccount() async throws -> User {
        // Get user account.
        let user = try await self.fetchAccount(with: self.userID)
        return user
    }
    
    /// Fetches the account of the currently authenticated user using the specified user ID.
    func fetchAccount(with userID: String) async throws -> User {
        let request = try UserAccountFetchRequest(with: userID)
        let (data, response) = try await URLSession.shared.data(for: request.urlRequest())
        
        guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else {
            throw UserAccountError.fetchRequestError
        }
        
        let user = try JSONDecoder().decode(User.self, from: data)
        return user
    }
}
