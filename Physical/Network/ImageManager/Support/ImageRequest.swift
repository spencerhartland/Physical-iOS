//
//  ImageRequest.swift
//  Physical
//
//  Created by Spencer Hartland on 8/2/23.
//

import Foundation

extension ImageManager {
    final class ImageRequest: HTTPSRequest {
        private let imageAPIHost = "api.spencerhartland.com"
        private let imageAPIPathPrefix = "physical-ios"
        private let imageAPIPathFileExtension = ".png"
        private let imageAPIHeaders = [
            HTTPHeader(field: .contentType, value: "image/png"),
            HTTPHeader(field: .accept, value: "image/png")
        ]
        
        init(forImageWithKey key: String, method: HTTPMethod = .GET, body: Data? = nil) {
            super.init(
                host: imageAPIHost,
                path: "/\(imageAPIPathPrefix)/\(key)/\(imageAPIPathFileExtension)",
                method: method,
                headers: imageAPIHeaders,
                body: body
            )
        }
    }
}
