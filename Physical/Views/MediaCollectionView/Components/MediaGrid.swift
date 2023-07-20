//
//  MediaGrid.swift
//  Physical
//
//  Created by Spencer Hartland on 7/18/23.
//

import SwiftUI
import SwiftData

struct MediaGrid: View {
    private let allMediaSectionHeaderText = "All media"
    
    var collection: [Media]
    
    init(_ collection: [Media]) {
        self.collection = collection
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 128))], alignment: .leading) {
                // All media
                Section {
                    ForEach(collection) {
                        MediaThumbnail(for: $0, ornamented: true)
                    }
                } header: {
                    Text(allMediaSectionHeaderText)
                        .font(.title.weight(.semibold))
                }
            }
            .padding()
        }
    }
}
