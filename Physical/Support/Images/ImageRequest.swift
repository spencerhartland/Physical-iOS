//
//  ImageRequest.swift
//  Physical
//
//  Created by Spencer Hartland on 8/2/23.
//

import Foundation

extension ImageManager {
    enum ImageRequestError: String, Error {
        case invalidURL
    }
    
    final class ImageRequest {
        private static let scheme = "https"
        private static let host = "api.spencerhartland.com"
        private static let bucketName = "physical-ios"
        
        enum HTTPMethod: String {
            case GET, PUT
        }
        
        static func urlRequest(forKey key: String, method: HTTPMethod) throws -> URLRequest {
            let url = try url(forKey: key)
            return URLRequest(url: url)
        }
        
        static func url(forKey key: String) throws -> URL {
            var components = URLComponents()
            components.scheme = ImageRequest.scheme
            components.host = ImageRequest.host
            components.path = "\(ImageRequest.bucketName)/\(key).png"
            
            guard let url = components.url else {
                throw ImageRequestError.invalidURL
            }
            
            return url
        }
    }
}
