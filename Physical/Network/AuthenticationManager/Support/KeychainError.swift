//
//  KeychainError.swift
//  Physical
//
//  Created by Spencer Hartland on 10/24/23.
//

import Foundation

enum KeychainError: Error {
    case keychainItemNotFound
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}
