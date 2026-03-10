//
//  KeychainManager.swift
//  Physical
//
//  Created by Spencer Hartland on 7/5/25.
//

import Foundation
import Security

enum TokenType: String {
    case SIWARefreshToken = "physical-siwa-refresh-token"
    case accessToken = "physical-api-access-token"
    case refreshToken = "physical-api-refresh-token"
}

struct KeychainManager {
    public static func storeCredentials(_ credentials: Credentials) throws {
        try storeToken(credentials.SIWARefreshToken, ofType: .SIWARefreshToken)
        try storeToken(credentials.accessToken, ofType: .accessToken)
        try storeToken(credentials.refreshToken, ofType: .refreshToken)
    }
    
    public static func storeToken(_ token: String, ofType tokenType: TokenType) throws {
        if let data = token.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: tokenType.rawValue,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status != errSecDuplicateItem else {
                throw KeychainError.duplicateItem
            }
            guard status == errSecSuccess else {
                throw KeychainError.unknownError(status)
            }
        }
    }
    
    public static func getToken(ofType tokenType: TokenType) -> String? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenType.rawValue,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
}
