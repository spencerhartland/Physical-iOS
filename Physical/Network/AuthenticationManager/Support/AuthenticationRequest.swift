//
//  AuthenticationRequest.swift
//  Physical
//
//  Created by Spencer Hartland on 10/19/23.
//

import Foundation

extension AuthenticationManager {
    final class AuthenticationRequest: HTTPSRequest {
        private let authAPIHost = "physical.spencerhartland.com"
        private let authAPIPath = "/auth"
        private let authAPIHeaders = [
            HTTPHeader(field: .contentType, value: "application/json")
        ]
        private let grantTypeKey = "grantType"
        private let authCodeKey = "authorizationCode"
        private let refreshTokenKey = "refreshToken"
        private let identityTokenKey = "identityToken"
        
        init(using token: String, identityToken: String? = nil, grantType: GrantType) throws {
            let tokenData = [
                grantTypeKey: grantType.rawValue,
                (grantType == .authorizationCode ? authCodeKey : refreshTokenKey): token,
                identityTokenKey: identityToken ?? ""
            ]
            guard let authData = try? JSONEncoder().encode(tokenData) else {
                throw AuthenticationError.authorizationCodeEncodeError
            }
            
            super.init(
                host: authAPIHost,
                path: authAPIPath,
                method: .POST,
                headers: authAPIHeaders,
                body: authData
            )
        }
        
        enum GrantType: String {
            case authorizationCode = "authorization_code"
            case refreshToken = "refresh_token"
        }
    }
}
