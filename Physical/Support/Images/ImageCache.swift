//
//  ImageCache.swift
//  Physical
//
//  Created by Spencer Hartland on 8/2/23.
//

import Foundation
import UIKit

extension ImageManager {
    enum ImageCacheError: String, Error {
        case cachesDirectoryWriteError
        case cachesDirectoryRemoveError
        case invalidCachesDirectoryURL
    }
    
    final class ImageCache {
        private var cache: NSCache<NSString, UIImage> = NSCache()
        
        static let shared = ImageCache()
        
        func add(_ image: UIImage, forKey key: String) throws {
            // Add to NSCache
            cache.setObject(image, forKey: key as NSString)
            // Add to ~/Library/Caches
            guard let data = image.pngData() else {
                throw ImageManagerError.unsupportedImageType
            }
            let url = try filePath(forKey: key)
            try data.write(to: url)
        }
        
        func retrieveImage(forKey key: String) throws -> UIImage {
            // Try to retrieve from NSCache
            if let cachedImage = cache.object(forKey: key as NSString) {
                return cachedImage
            }
            
            // Not in NSCache, check Caches dir
            let url = try filePath(forKey: key)
            let data = try Data(contentsOf: url)
            
            guard let image = UIImage(data: data) else {
                throw ImageManagerError.unsupportedImageType
            }
            
            return image
        }
        
        func removeImage(forKey key: String) throws {
            // Remove from NSCache
            cache.removeObject(forKey: key as NSString)
            // Remove from Caches dir
            let url = try filePath(forKey: key)
            try FileManager.default.removeItem(at: url)
        }
        
        // Path to images in Caches directory
        private func filePath(forKey key: String) throws -> URL {
            let fileManager = FileManager.default
            guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                throw ImageCacheError.invalidCachesDirectoryURL
            }
            return cacheDirectory.appending(path: "\(key).png")
        }
    }
}
