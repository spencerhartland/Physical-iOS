//
//  ImageManager.swift
//  Physical
//
//  Created by Spencer Hartland on 8/2/23.
//

import Foundation
import UIKit

enum ImageManagerError: String, Error {
    case InvalidResponse = "HTTP response is invalid or indicates error."
    case UnsupportedImageType = "The image type is unsupported."
    case ImageFetchError = "There was an issue fetching the image."
    case ImageDataError = "There was an issue getting PNG data from the image."
}

final class ImageManager {
    private let scheme = "https"
    private let host = "api.spencerhartland.com"
    private let bucketName = "physical-ios"
    private let cache = ImageCache.shared
    
    /// Retrieves the image associated with the provided key.
    ///
    /// First checks NSCache (best performance), then checks `Caches` directory (better performance).
    /// If the image is not located in either cache location, it is retrieved from server (good performance).
    /// - Parameter key: The images's assigned key.
    /// - Returns: The image, if it exists. Otherwise, nil.
    func retrieveImage(forKey key: String) async -> UIImage? {
        // First try the caches
        if let cachedImage = cache.retrieveImage(forKey: key) {
            return cachedImage
        }
        
        // Try fetching from server
        guard let url = try? ImageRequest.url(forKey: key),
              let image = try? await fetchImage(url: url) else {
            return nil
        }
        
        return image
    }
    
    /// Caches the image in NSCache and the Caches directory
    ///
    /// - Parameters:
    ///   - image: The UIImage object to be cached.
    ///   - key: The image's assigned key.
    func cache(_ image: UIImage, forKey key: String) {
        // First, cache locally
        cache.add(image, forKey: key)
    }
    
    /// Uploads the image to server for long-term storage and public availability.
    ///
    /// - Parameters:
    ///   - image: The image to be uploaded.
    ///   - request: The `URLRequest` to use for this upload.
    func upload(_ image: UIImage, request: URLRequest) async throws {
        do {
            guard let imageData = image.pngData() else {
                throw ImageManagerError.ImageDataError
            }
            
            let (_, response) = try await URLSession.shared.upload(for: request, from: imageData)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 201 /* Created */ else {
                throw ImageManagerError.InvalidResponse
            }
        }
    }
    
    /// Removes the image from both cache locations and server.
    ///
    /// This action cannot be undone. The image will be removed from all storage locations.
    /// - Parameter key: The image's assigned key.
    func removeImage(forKey key: String) {
        cache.removeImage(forKey: key)
        // TODO: Remove from server and remove key from media
    }
    
    private func fetchImage(url: URL) async throws -> UIImage {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw ImageManagerError.InvalidResponse
            }
            
            guard let image = UIImage(data: data) else {
                throw ImageManagerError.UnsupportedImageType
            }
            
            return image
        } catch {
            throw ImageManagerError.ImageFetchError
        }
    }
}
