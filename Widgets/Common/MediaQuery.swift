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
            predicate: #Predicate { identifiers.contains($0.id) && $0.isFavorite },
            sortBy: [.init(\.dateAdded, order: .reverse)]
        )
        return try modelContainer.mainContext.fetch(descriptor).map(MediaEntity.init(from:))
    }
    
    @MainActor
    func suggestedEntities() async throws -> [MediaEntity] {
        try fetchFavorites()
    }
    
    @MainActor
    func defaultResult() async -> MediaEntity? {
        try? fetchFavorites(limit: 1).first
    }
    
    @MainActor
    private func fetchFavorites(limit: Int? = nil) throws -> [MediaEntity] {
        var descriptor = FetchDescriptor<Media>(
            predicate: #Predicate { $0.isFavorite },
            sortBy: [.init(\.dateAdded, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContainer.mainContext.fetch(descriptor).map(MediaEntity.init(from:))
    }
}
