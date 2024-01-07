//
//  HTTPSRequest.swift
//  Physical
//
//  Created by Spencer Hartland on 8/3/23.
//

import Foundation

enum HTTPMethod: String {
    case GET, PUT, POST
}

struct HTTPHeader {
    let field: Field
    let value: String
    
    enum Field: String {
        case contentType = "Content-Type"
        case accept = "Accept"
        case authorization = "Authorization"
    }
}

class HTTPSRequest {
    private let scheme = "https"
    
    let host: String
    let path: String
    let queryItems: [URLQueryItem]?
    let method: HTTPMethod
    let headers: [HTTPHeader]
    let body: Data?
    
    lazy var url: URL? = {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
        
        return components.url
    }()
    
    init(host: String, path: String, queryItems: [URLQueryItem]? = nil, method: HTTPMethod, headers: [HTTPHeader], body: Data? = nil) {
        self.host = host
        self.path = path
        self.queryItems = queryItems
        self.method = method
        self.headers = headers
        self.body = body
    }
    
    func urlRequest() throws -> URLRequest {
        if let url {
            //print(url.absoluteString)
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.field.rawValue)
            }
            request.httpBody = body
            
            //print(String(data: body!, encoding: .utf8)!)
            
            return request
        }
        
        throw NetworkError.invalidURL
    }
}
