//
//  Credentials.swift
//  Physical
//
//  Created by Spencer Hartland on 10/25/23.
//

import Foundation

struct Credentials: Decodable {
    let SIWARefreshToken: String
    let accessToken: String
    let refreshToken: String
}
