//
//  ImageManager.swift
//  Physical
//
//  Created by Spencer Hartland on 7/17/23.
//

import SwiftData
import UIKit
import SwiftUI
import MusicKit

enum ImageManagerError: Error {
    case invalidURL, unableToGetURLFromArtwork, invalidImageData
}

/// Provides methods to asyncronously load and cache image assets.
@Observable
final class ImageManager {
    private var cache: NSCache<NSString, UIImage> = NSCache()
    var image: UIImage? = nil
    
    /// Caches an image locally.
    ///
    /// - Parameters:
    ///     - image: The image to cache.
    func cache(_ image: UIImage, key: String) {
        let nsString = NSString(string: key)
        cache.setObject(image, forKey: nsString)
    }
    
    /// Asyncronously loads  an image from the provided `URL`.
    ///
    /// - Parameters:
    ///    - url: The url to load an image from
    func load(_ url: URL?) async throws {
        // Unwrap the image URL
        guard let url = url else {
            throw ImageManagerError.invalidURL
        }
        
        // Check if the image is in cache
        let nsString = NSString(string: url.absoluteString)
        if let cachedImage = cache.object(forKey: nsString) {
            self.image = cachedImage
            return
        }
        
        // Load image from URL
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let downloadedImage = UIImage(data: data) else {
            throw ImageManagerError.invalidImageData
        }
        cache.setObject(downloadedImage, forKey: nsString)
        image = downloadedImage
    }
    
     /// Asyncronously loads  an image from the url for the provided `Artwork`.
     ///
     /// - Parameters:
     ///    - artwork: an instance of `Artwork`
    func load(_ artwork: Artwork?) async throws {
        // Unwrap the artwork
        guard let artwork = artwork,
        let url = artwork.url(width: 1080, height: 1080) else {
            throw ImageManagerError.unableToGetURLFromArtwork
        }
        
        // Check if the image is in cache
        let nsString = NSString(string: url.absoluteString)
        if let cachedImage = cache.object(forKey: nsString) {
            self.image = cachedImage
            return
        }
        
        // Load image from URL
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let downloadedImage = UIImage(data: data) else {
            throw ImageManagerError.invalidImageData
        }
        cache.setObject(downloadedImage, forKey: nsString)
        image = downloadedImage
    }
}
