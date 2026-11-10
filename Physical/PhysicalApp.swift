//
//  PhysicalApp.swift
//  Vinyls
//
//  Created by Spencer Hartland on 7/5/23.
//

import AppIntents
import OSLog
import PhysicalMediaKit
import SwiftUI
import SwiftData

@main
struct PhysicalApp: App {
    private static let appGroupID = "group.physical"
    private static let favoritesPreparedKey = "preexistingFavoritesPreparedForWidgets"
    
    @State private var navigationManager: NavigationManager = NavigationManager()
    
    let sharedModelContainer: ModelContainer
    
    init() {
        ValueTransformer.setValueTransformer(
            UIColorValueTransformer(),
            forName: NSValueTransformerName("UIColorValueTransformer")
        )
        
        guard let appGroupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Self.appGroupID
        ) else {
            fatalError("App Group container not available.")
        }
        
        // Configure thumbnail cache
        let thumbnailCacheURL = appGroupURL
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Caches", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: thumbnailCacheURL,
            withIntermediateDirectories: true
        )
        PhysicalMedia.configureThumbnailCache(with: thumbnailCacheURL)
        
        let newStoreURL = appGroupURL.appendingPathComponent("default.store")
        Self.migrateStoreIfNeeded(to: newStoreURL)
        
        let schema = Schema([Media.self])
        let modelConfig = ModelConfiguration(
            schema: schema,
            url: newStoreURL,
            allowsSave: true
        )
        
        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: modelConfig)
            Self.createUniqueMediaIDs(in: sharedModelContainer.mainContext)
            Self.prepareFavoritesForWidgetsIfNeeded(in: sharedModelContainer.mainContext)
        } catch {
            fatalError("Could not create model container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(navigationManager)
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: Physical V1 -> V1.1 Migration -
    
    @MainActor
    private static func createUniqueMediaIDs(in context: ModelContext) {
        guard let allMedia = try? context.fetch(FetchDescriptor<Media>()),
              Set(allMedia.map(\.id)).count < allMedia.count else {
            return
        }
        for item in allMedia {
            item.id = UUID()
        }
        try? context.save()
    }
    
    @MainActor
    private static func prepareFavoritesForWidgetsIfNeeded(in context: ModelContext) {
        // One-time render of favorites existing before widgets were introduced.
        guard !UserDefaults.standard.bool(forKey: Self.favoritesPreparedKey) else {
            return
        }
        
        let fetchDesc = FetchDescriptor<Media>(
            predicate: #Predicate { $0.isFavorite }
        )
        guard let favoriteMedia = try? context.fetch(fetchDesc) else {
            Logger.Standard.general.debug("Couldn't get favorites.")
            return
        }
        
        Task {
            Logger.Standard.general.debug("Preparing favorites for widgets...")
            await WidgetHelper.prepareFavoritesForWidget(favoriteMedia)
            try? context.save()
            WidgetHelper.reloadTimelines()
        }
        
        UserDefaults.standard.set(true, forKey: Self.favoritesPreparedKey)
    }

    private static func migrateStoreIfNeeded(to newStoreURL: URL) {
        let fileManager = FileManager.default
        
        guard !UserDefaults.standard.bool(forKey: "storeDidMigrate") else { return }
        
        guard let defaultDirectory = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else { return }
        
        let oldStoreURL = defaultDirectory.appendingPathComponent("default.store")
        guard fileManager.fileExists(atPath: oldStoreURL.path) else { return }
        
        let suffixes = ["", "-shm", "-wal"]
        for suffix in suffixes {
            let source = URL(fileURLWithPath: oldStoreURL.path + suffix)
            let destination = URL(fileURLWithPath: newStoreURL.path + suffix)
            
            guard fileManager.fileExists(atPath: source.path) else { continue }
            
            do {
                try? fileManager.removeItem(at: destination)
                try fileManager.copyItem(at: source, to: destination)
            } catch {
                Logger.Standard.general.error("Failed to migrate store file '\(suffix)': \(error)")
            }
        }
        
        UserDefaults.standard.set(true, forKey: "storeDidMigrate")
    }
}
