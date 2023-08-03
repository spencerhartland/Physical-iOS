//
//  HTTPRequest.swift
//  Physical
//
//  Created by Spencer Hartland on 8/3/23.
//

import Foundation

enum HTTPMethod: String {
    case GET, PUT
}

struct HTTPHeader {
    let field: Field
    let value: String
    
    enum Field: String {
        case contentType = "Content-Type"
        case accept = "Accept"
    }
}
