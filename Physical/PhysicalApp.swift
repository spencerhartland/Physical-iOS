//
//  PhysicalApp.swift
//  Vinyls
//
//  Created by Spencer Hartland on 7/5/23.
//

import SwiftUI
import SwiftData

@main
struct PhysicalApp: App {
    var body: some Scene {
        WindowGroup {
            MediaCollectionView()
        }
        .modelContainer(for: Media.self)
    }
}
