//
//  MediaWidgetBundle.swift
//  MediaWidget
//
//  Created by Spencer Hartland on 5/11/26.
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents
import PhysicalMediaKit

@main
struct MediaWidgetBundle: WidgetBundle {
    init() {
        let appGroupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.physical"
        )!
        
        // Thumbnail cache configuration
        let thumbnailCacheURL = appGroupURL
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Caches", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: thumbnailCacheURL,
            withIntermediateDirectories: true
        )
        
        PhysicalMedia.configureThumbnailCache(with: thumbnailCacheURL)
        
        // SwiftData configuration
        let schema = Schema([Media.self])
        let storeURL = appGroupURL.appendingPathComponent("default.store")
        let modelConfig = ModelConfiguration(schema: schema, url: storeURL)
        
        ValueTransformer.setValueTransformer(
            UIColorValueTransformer(),
            forName: NSValueTransformerName("UIColorValueTransformer")
        )
        
        do {
            let modelContainer = try ModelContainer(for: schema, configurations: modelConfig)
            AppDependencyManager.shared.add(dependency: modelContainer)
        } catch {
            fatalError("Could not create model container: \(error)")
        }
    }
    
    var body: some Widget {
        FavoritesDisplayWidget()
        MediaDisplayWidget()
    }
}


