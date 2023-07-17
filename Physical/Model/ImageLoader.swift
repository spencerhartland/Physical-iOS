//
//  ImageLoader.swift
//  Physical
//
//  Created by Spencer Hartland on 7/17/23.
//

import SwiftData
import UIKit
import MusicKit

enum ImageLoaderError: Error {
    case invalidURL, unableToGetURLFromArtwork, invalidImageData
}

/// Provides methods to asyncronously load and cache image assets.
@Observable
final class ImageLoader {
    private var cache: NSCache<NSString, UIImage> = NSCache()
    var image: UIImage? = nil
    private var imageWidth: Int
    private var imageHeight: Int
    
    init(width: Int = 1080, height: Int = 1080) {
        imageWidth = width
        imageHeight = height
    }
    
    /// Asyncronously loads  an image from the provided `URL`.
    ///
    /// - Parameters:
    ///    - url: The url to load an image from
    func load(_ url: URL?) async throws {
        // Unwrap the image URL
        guard let url = url else {
            throw ImageLoaderError.invalidURL
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
            throw ImageLoaderError.invalidImageData
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
        let url = artwork.url(width: imageWidth, height: imageHeight) else {
            throw ImageLoaderError.unableToGetURLFromArtwork
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
            throw ImageLoaderError.invalidImageData
        }
        cache.setObject(downloadedImage, forKey: nsString)
        image = downloadedImage
    }
}
