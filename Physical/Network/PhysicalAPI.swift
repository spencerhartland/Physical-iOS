//
//  PhysicalAPI.swift
//  Physical
//
//  Created by Spencer Hartland on 12/21/23.
//

import Foundation

struct PhysicalAPI {
    static let host = "physical.spencerhartland.com"
    static let authEndpointPath = "/auth"
    static let userEndpointPath = "/user"
    static let userIDEndpointPath = "/userID"
    static let standardHeaders = [
        HTTPHeader(field: .contentType, value: "application/json")
    ]
}
