//
//  ImageManager.swift
//  Physical
//
//  Created by Spencer Hartland on 8/2/23.
//

import Foundation
import UIKit

final class ImageManager {
    private let cache = ImageCache.shared
    
    /// Caches the image in NSCache and the Caches directory
    ///
    /// - Parameters:
    ///   - image: The UIImage object to be cached.
    ///   - key: The image's assigned key.
    func cache(_ image: UIImage, forKey key: String) {
        cache.add(image, forKey: key)
    }
    
    /// Retrieves the image associated with the provided key.
    ///
    /// First checks NSCache (best performance), then checks `Caches` directory (better performance).
    /// If the image is not located in either cache location, it is retrieved from server (good performance).
    /// - Parameter key: The images's assigned key.
    /// - Returns: The image, if it exists. Otherwise, nil.
    func retrieveImage(forKey key: String) -> UIImage? {
        // First try the caches
        if let cachedImage = cache.retrieveImage(forKey: key) {
            return cachedImage
        }
        
        // Try fetching from server
        if let image = fetchImage(forKey: key) {
            return image
        }
        
        // Unable to retrieve an image for the provided key
        return nil
    }
    
    /// Removes the image from both cache locations and server.
    ///
    /// This action cannot be undone. The image will be removed from all storage locations.
    /// - Parameter key: The image's assigned key.
    func removeImage(forKey key: String) {
        cache.removeImage(forKey: key)
    }
    
    private func fetchImage(forKey key: String) -> UIImage? {
        // Fetch the image from AWS...
        return nil
    }
    
    private func uploadImage(forKey key: String) {
        // Upload the image to AWS
    }
}
