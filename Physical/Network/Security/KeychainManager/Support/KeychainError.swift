//
//  KeychainError.swift
//  Physical
//
//  Created by Spencer Hartland on 10/24/23.
//

import Foundation

extension KeychainManager {
    enum KeychainError: Error {
        case duplicateItem
        case keychainItemNotFound
        case unexpectedPasswordData
        case unknownError(OSStatus)
    }
}
