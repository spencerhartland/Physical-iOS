//
//  ImageRequest.swift
//  Physical
//
//  Created by Spencer Hartland on 8/2/23.
//

import Foundation
import UIKit

extension ImageManager {
    final class ImageRequest {
        private let scheme = "https"
        private let host = "api.spencerhartland.com"
        private let bucketName = "physical-ios"
        
        func urlRequest(forKey key: String, method: HTTPMethod) -> URLRequest? {
            if let url = url(forKey: key) {
                var request = URLRequest(url: url)
                request.httpMethod = method.rawValue
            }
            
            return nil
        }
        
        enum HTTPMethod: String {
            case GET, PUT
        }
        
        private func url(forKey key: String) -> URL? {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = "\(bucketName)/\(key).png"
            
            return components.url
        }
    }
}
