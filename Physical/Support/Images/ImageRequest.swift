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
        
        enum HTTPMethod: String {
            case GET, PUT
        }
        
        static func urlRequest(forKey key: String, method: HTTPMethod) -> URLRequest? {
            if let url = url(forKey: key) {
                var request = URLRequest(url: url)
                request.httpMethod = method.rawValue
            }
            
            return nil
        }
        
        static func url(forKey key: String) -> URL? {
            var components = URLComponents()
            components.scheme = ImageRequest.scheme
            components.host = ImageRequest.host
            components.path = "\(ImageRequest.bucketName)/\(key).png"
            
            return components.url
        }
    }
}
