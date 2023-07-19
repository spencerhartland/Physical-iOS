//
//  MediaGrid.swift
//  Physical
//
//  Created by Spencer Hartland on 7/18/23.
//

import SwiftUI
import SwiftData

struct MediaGrid: View {
    var collection: [Media]
    
    init(_ collection: [Media]) {
        self.collection = collection
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 128))]) {
                ForEach(collection) {
                    MediaThumbnail(for: $0)
                }
            }
            .padding()
        }
    }
}
