//
//  User.swift
//  Vinyls
//
//  Created by Spencer Hartland on 7/5/23.
//

import Foundation
import SwiftData

@Model
final class Collection {
    let firstName: String
    let lastName: String
    @Attribute(.unique) let userName: String
    
    init(firstName: String, lastName: String, userName: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
    }
}
