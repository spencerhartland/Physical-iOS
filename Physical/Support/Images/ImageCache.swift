//
//  ImageCache.swift
//  Physical
//
//  Created by Spencer Hartland on 8/2/23.
//

import Foundation
import UIKit

extension ImageManager {
    final class ImageCache {
        private var cache: NSCache<NSString, UIImage> = NSCache()
        
        static let shared = ImageCache()
        
        func add(_ image: UIImage, forKey key: String) {
            // Add to NSCache
            cache.setObject(image, forKey: key as NSString)
            // Add to ~/Library/Caches
            if let data = image.pngData(),
               let url = filePath(forKey: key) {
                do {
                    try data.write(to: url)
                } catch {
                    print("Error writing to Caches dir: \(error.localizedDescription)")
                }
            }
        }
        
        func retrieveImage(forKey key: String) -> UIImage? {
            // Try to retrieve from NSCache
            if let cachedImage = cache.object(forKey: key as NSString) {
                return cachedImage
            }
            
            // Not in NSCache, check Caches dir
            if let url = filePath(forKey: key),
               let data = try? Data(contentsOf: url) {
                return UIImage(data: data)
            }
            
            // Image not found in any caches
            return nil
        }
        
        func removeImage(forKey key: String) {
            // Remove from NSCache
            cache.removeObject(forKey: key as NSString)
            // Remove from Caches dir
            if let url = filePath(forKey: key) {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    print("Error removing item from Caches dir: \(error.localizedDescription)")
                }
            }
        }
        
        // Path to images in Caches directory
        private func filePath(forKey key: String) -> URL? {
            let fileManager = FileManager.default
            guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
            return cacheDirectory.appending(path: "\(key).png")
        }
    }
}
