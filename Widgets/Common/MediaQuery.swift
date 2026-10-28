//
//  MediaQuery.swift
//  Physical
//
//  Created by Spencer Hartland on 5/11/26.
//

import Foundation
import AppIntents
import SwiftData

struct MediaQuery: EntityQuery {
    @Dependency private var modelContainer: ModelContainer
    
    @MainActor
    func entities(for identifiers: [MediaEntity.ID]) async throws -> [MediaEntity] {
        let descriptor = FetchDescriptor<Media>(
            predicate: #Predicate { identifiers.contains($0.id) },
            sortBy: [.init(\.dateAdded)],
        )
        let media = try modelContainer.mainContext.fetch(descriptor)
        
        return media.map { item in
            return MediaEntity(
                id: item.id,
                type: item.type,
                title: item.title,
                artist: item.artist,
                albumArtworkURL: item.albumArtworkURL,
                color: item.color
            )
        }
    }
    
    @MainActor
    func suggestedEntities() async throws -> [MediaEntity] {
        let favorites = FetchDescriptor<Media>(
            predicate: #Predicate { $0.isFavorite == true },
            sortBy: [.init(\.dateAdded)]
        )
        let allMedia = FetchDescriptor<Media>(
            sortBy: [.init(\.dateAdded)]
        )
        
        var media = try modelContainer.mainContext.fetch(favorites)
        if media.isEmpty,
           let latestAddition = try modelContainer.mainContext.fetch(allMedia).first {
            media = [latestAddition]
        }
        
        return media.map { item in
            return MediaEntity(
                id: item.id,
                type: item.type,
                title: item.title,
                artist: item.artist,
                albumArtworkURL: item.albumArtworkURL,
                color: item.color
            )
        }
    }
    
    @MainActor
    func defaultResult() async -> MediaEntity? {
        let descriptor = FetchDescriptor<Media>(
            sortBy: [.init(\.dateAdded)]
        )
        do {
            let media = try modelContainer.mainContext.fetch(descriptor)
            
            if let latestAddition = media.first {
                return MediaEntity(
                    id: latestAddition.id,
                    type: latestAddition.type,
                    title: latestAddition.title,
                    artist: latestAddition.artist,
                    albumArtworkURL: latestAddition.albumArtworkURL,
                    color: latestAddition.color
                )
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}
