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
            return MediaEntity(from: item)
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
            return MediaEntity(from: item)
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
                return MediaEntity(from: latestAddition)
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}
