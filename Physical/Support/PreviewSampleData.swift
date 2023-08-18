//
//  PreviewSampleData.swift
//  Physical
//
//  Created by Spencer Hartland on 8/16/23.
//

import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: Media.self, ModelConfiguration(inMemory: true)
        )
        for item in SampleCollection.contents {
            container.mainContext.insert(item)
        }
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()
