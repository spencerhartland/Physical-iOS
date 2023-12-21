//
//  UserAccountRequest.swift
//  Physical
//
//  Created by Spencer Hartland on 12/21/23.
//

import Foundation

extension UserAccountManager {
    final class UserAccountFetchRequest: HTTPSRequest {
        private let userIDKey = "userID"
        
        init(for userID: String) throws {
            let requestData = [
                userIDKey: userID
            ]
            guard let encodedRequestData = try? JSONEncoder().encode(requestData) else {
                throw UserAccountError.requestDataEncodeError
            }
            
            super.init(
                host: PhysicalAPI.host,
                path: PhysicalAPI.userEndpointPath,
                method: .GET,
                headers: PhysicalAPI.standardHeaders,
                body: encodedRequestData
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
