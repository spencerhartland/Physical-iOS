//
//  FavoritesDisplayWidget-MediaProvider.swift
//  Physical
//
//  Created by Spencer Hartland on 5/18/26.
//

import Foundation
import PhysicalMediaKit
import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

extension FavoritesDisplayWidget {
    struct MediaProvider: TimelineProvider {
        typealias Entry = FavoritesDisplayEntry
        
        func placeholder(in context: Context) -> Entry { Entry() }
        
        func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
            Task {
                do {
                    var allFavorites = try fetchFavorites()
                    
                    var entries: [Entry] = []
                    let currentDate = Date()
                    
                    for entry in 0..<48 {
                        guard !allFavorites.isEmpty else { break }
                        
                        let minutes = entry * 30
                        let entryDate = Calendar.current.date(
                            byAdding: .minute,
                            value: minutes,
                            to: currentDate
                        )!
                        
                        var favorites: [MediaEntity] = []
                        for favoriteIndex in 0..<3 {
                            guard !allFavorites.isEmpty else { break }
                            if favoriteIndex == 0 {
                                let displayFavorite = allFavorites.removeFirst()
                                favorites.append(displayFavorite)
                            } else {
                                let index = favoriteIndex - 1
                                guard index < allFavorites.count else { break }
                                let upcomingFavorite = allFavorites[index]
                                favorites.append(upcomingFavorite)
                            }
                        }
                        
                        let thumbnailKeys = retrieveThumbnailKeys(for: favorites)
                        
                        let entry = Entry(
                            date: entryDate,
                            favorites: favorites,
                            thumbnailKeys: thumbnailKeys
                        )
                        entries.append(entry)
                    }
                    
                    completion(Timeline(entries: entries, policy: .atEnd))
                } catch {
                    completion(Timeline(entries: [], policy: .atEnd))
                }
            }
        }
        
        func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
            Task {
                do {
                    // Fetch media, render thumbnails
                    let allFavorites = try fetchFavorites()
                    var favorites: [MediaEntity] = []
                    for (index, favorite) in allFavorites.enumerated() {
                        guard index < 3 else { break } // Snapshot only the first 3 favorites
                        favorites.append(favorite)
                    }
                    let thumbnailKeys = retrieveThumbnailKeys(for: favorites)
                    
                    let entry = Entry(
                        date: .now,
                        favorites: favorites,
                        thumbnailKeys: thumbnailKeys
                    )
                    
                    completion(entry)
                } catch {
                    completion(Entry(date: .now, favorites: [], thumbnailKeys: []))
                }
            }
        }
        
        private func fetchFavorites() throws -> [MediaEntity] {
            let context = modelContext()
            let favoriteMedia = FetchDescriptor<Media>(
                predicate: #Predicate { $0.isFavorite == true },
                sortBy: [.init(\.dateAdded)]
            )
            let favorites = try context.fetch(favoriteMedia)
            
            return favorites.map { favorite in
                return MediaEntity(from: favorite)
            }
        }
        
        private func retrieveThumbnailKeys(for favorites: [MediaEntity]) -> [String] {
            var keys: [String] = []
            
            for (index, favorite) in Array(favorites.enumerated()) {
                let scaleOffset: Float = 0.04 * pow(0.5, Float(index))
                let rotationY: Float = (index == 0 ? 0 : (-0.4 - (0.075 * Float(index))))
                
                switch favorite.type {
                case .vinylRecord:
                    let scale: Float = 0.11 + scaleOffset
                    
                    keys.append(
                        PhysicalMedia.cacheKey(
                            for: .vinylRecord,
                            artworkURL: favorite.albumArtworkURL,
                            mediaColor: favorite.color,
                            scale: scale,
                            rotationXY: (0, rotationY),
                        )
                    )
                case .compactDisc:
                    let scale: Float = 0.155 + scaleOffset
                    // by default, the CD model is slight askew on the y axis to show the disc; if
                    // the CD is in the first position, it should be adjusted to be parallel to
                    // the screen.
                    let rotationYOffset: Float = (index == 0 ? 0.18 : 0)
                    
                    keys.append(
                        PhysicalMedia.cacheKey(
                            for: .compactDisc,
                            artworkURL: favorite.albumArtworkURL,
                            mediaColor: nil,
                            scale: scale,
                            rotationXY: (0, (rotationY + rotationYOffset)),
                        )
                    )
                case .compactCassette:
                    let scale: Float = 0.31 + scaleOffset
                    
                    keys.append(
                        PhysicalMedia.cacheKey(
                            for: .compactCassette,
                            artworkURL: favorite.albumArtworkURL,
                            mediaColor: favorite.color,
                            scale: scale,
                            rotationXY: (0, rotationY),
                        )
                    )
                }
            }
            
            return keys
        }
        
        private func modelContext() -> ModelContext {
            let schema = Schema([Media.self])
            guard let appGroupURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.physical"
            ) else {
                fatalError("Could not get container URL for app group ID.")
            }
            let storeURL = appGroupURL.appendingPathComponent("default.store")
            let modelConfig = ModelConfiguration(schema: schema, url: storeURL)
            
            do {
                let container = try ModelContainer(for: schema, configurations: modelConfig)
                return ModelContext(container)
            } catch {
                fatalError("Could not create `ModelContainer`: \(error)")
            }
        }
    }
}
