//
//  ImageManager.swift
//  Physical
//
//  Created by Spencer Hartland on 8/2/23.
//

import Foundation
import UIKit

final class ImageManager {
    private let scheme = "https"
    private let host = "physical.spencerhartland.com"
    private let bucketName = "physical-ios"
    private let cache = ImageCache.shared
    
    static let shared = ImageManager()
    
    /// Retrieves the image associated with the provided key.
    ///
    /// First checks NSCache (best performance), then checks `Caches` directory (better performance).
    /// If the image is not located in either cache location, it is retrieved from server (good performance).
    /// - Parameter key: The images's assigned key.
    /// - Returns: The image, if it exists. Otherwise, nil.
    func retrieveImage(withKey key: String) async throws -> UIImage {
        // First try the caches
        do {
            let cachedImage = try cache.retrieveImage(forKey: key)
            
            return cachedImage
        } catch {
            print(error.localizedDescription)
        }
        
        // Try fetching from server
        do {
            let imageRequest = ImageRequest(forImageWithKey: key)
            guard let url = imageRequest.url else {
                throw NetworkError.invalidURL
            }
            let image = try await fetchImage(url: url)
            
            return image
        } catch {
            print(error.localizedDescription)
            throw NetworkError.imageDoesNotExist
        }
    }
    
    /// Caches the image in NSCache and the Caches directory
    ///
    /// - Parameters:
    ///   - image: The UIImage object to be cached.
    ///   - key: The image's assigned key.
    func cache(_ image: UIImage, withKey key: String) throws {
        // First, cache locally
        try cache.add(image, forKey: key)
    }
    
    /// Uploads the image to server for long-term storage and public availability.
    /// 
    /// - Parameters:
    ///   - image: The image to be uploaded.
    ///   - request: The `URLRequest` to use for this upload.
    ///
    /// - Returns: The UUID string assigned to this image.
    func upload(_ image: UIImage, withKey key: String) async throws {
        do {
            guard let imageData = image.pngData() else {
                throw NetworkError.imageDataError
            }
            
            let request = try ImageRequest(forImageWithKey: key, method: .PUT, body: imageData).urlRequest()
            let (_, response) = try await URLSession.shared.upload(for: request, from: imageData)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 201 /* Created */ else {
                throw NetworkError.invalidHTTPResponse
            }
        }
    }
    
    /// Uploads all images with keys matching the provided keys to server.
    ///
    /// - Parameter keys: The keys of the images to upload.
    func uploadFromCache(keys: [String]) async throws {
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for key in keys {
                    let image = try cache.retrieveImage(forKey: key)
                    group.addTask {
                        try await self.upload(image, withKey: key)
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Removes the image from both cache locations and server.
    ///
    /// This action cannot be undone. The image will be removed from all storage locations.
    /// - Parameter key: The image's assigned key.
    func removeImage(withKey key: String) throws {
        try cache.removeImage(forKey: key)
        // TODO: Remove from server and remove key from media
    }
    
    /// Fetches the image at the provided URL.
    ///
    /// - Parameter url: The URL at which the image is located.
    func fetchImage(url: URL) async throws -> UIImage {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NetworkError.invalidHTTPResponse
            }
            
            guard let image = UIImage(data: data) else {
                throw NetworkError.unsupportedImageType
            }
            
            return image
        } catch {
            throw NetworkError.imageFetchError
        }
    }
}
