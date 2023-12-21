//
//  UserAccountManager.swift
//  Physical
//
//  Created by Spencer Hartland on 12/21/23.
//

import Foundation

final class UserAccountManager {
    func createAccount(for user: User, _ completion: @escaping (Result<Void, Error>) -> Void) async {
        do {
            let request = try UserAccountCreationRequest(user)
            let (data, response) = try await URLSession.shared.data(for: request.urlRequest())
            
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode == 200 {
                completion(.success(Void()))
            }
            
            completion(.failure(UserAccountError.creationRequestError))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchAccount(for userID: String, _ completion: @escaping (Result<User, Error>) -> Void) async {
        do {
            let request = try UserAccountFetchRequest(for: userID)
            let (data, response) = try await URLSession.shared.data(for: request.urlRequest())
            
            let httpResponse = response as! HTTPURLResponse
            let user = try JSONDecoder().decode(User.self, from: data)
            
            if httpResponse.statusCode == 200 {
                completion(.success(user))
            }
            
            completion(.failure(UserAccountError.fetchRequestError))
        } catch {
            completion(.failure(error))
        }
    }
}
