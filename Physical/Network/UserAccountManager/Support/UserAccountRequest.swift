//
//  UserAccountRequest.swift
//  Physical
//
//  Created by Spencer Hartland on 12/21/23.
//

import Foundation

extension UserAccountManager {
    final class UserIDFetchRequest: HTTPSRequest {
        private let usernameKey = "username"
        
        init(for username: String) throws {
            super.init(
                host: PhysicalAPI.host,
                path: PhysicalAPI.userIDEndpointPath,
                queryItems: [ URLQueryItem(name: usernameKey, value: username) ],
                method: .GET,
                headers: PhysicalAPI.standardHeaders
            )
        }
    }
    
    final class UserAccountFetchRequest: HTTPSRequest {
        private let userIDKey = "userID"
        
        init(with userID: String) throws {
            super.init(
                host: PhysicalAPI.host,
                path: PhysicalAPI.userEndpointPath,
                queryItems: [
                    URLQueryItem(name: userIDKey, value: userID)
                ],
                method: .GET,
                headers: PhysicalAPI.standardHeaders
            )
        }
    }
    
    final class UserAccountCreationRequest: HTTPSRequest {
        init(_ user: User) throws {
            guard let encodedRequestData = try? JSONEncoder().encode(user) else {
                throw UserAccountError.requestDataEncodeError
            }
            
            super.init(
                host: PhysicalAPI.host,
                path: PhysicalAPI.userEndpointPath,
                method: .POST,
                headers: PhysicalAPI.standardHeaders,
                body: encodedRequestData
            )
        }
    }
}
