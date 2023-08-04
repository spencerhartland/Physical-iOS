//
//  ImageRequest.swift
//  Physical
//
//  Created by Spencer Hartland on 8/2/23.
//

import Foundation

extension ImageManager {
    final class ImageRequest {
        private static let scheme = "https"
        private static let host = "api.spencerhartland.com"
        private static let bucketName = "physical-ios"
        private static let headers = [
            HTTPHeader(field: .contentType, value: "image/png"),
            HTTPHeader(field: .accept, value: "image/png")
        ]
        
        static func urlRequest(forKey key: String, method: HTTPMethod) throws -> URLRequest {
            guard let url = url(forKey: key) else {
                print("Invalid URL constructed.")
                throw NetworkError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.field.rawValue)
            }
            
            return request
        }
        
        static func url(forKey key: String) -> URL? {
            var components = URLComponents()
            components.scheme = ImageRequest.scheme
            components.host = ImageRequest.host
            components.path = "/\(ImageRequest.bucketName)/\(key).png"
            
            return components.url
        }
    }
}
