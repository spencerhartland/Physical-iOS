//
//  MediaGrid.swift
//  Physical
//
//  Created by Spencer Hartland on 7/18/23.
//

import SwiftUI
import SwiftData

enum DisplayModes {
    case allMedia, sortByMediaType, sortByCondition
}

struct MediaGrid: View {
    private let allMediaSectionHeaderText = "All media"
    
    @Query(sort: \.dateAdded, order: .reverse) private var collection: [Media]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 128))], alignment: .leading) {
                // All media
                Section {
                    ForEach(collection) { media in
                        NavigationLink {
                            MediaDetailView(media: media)
                        } label: {
                            MediaThumbnail(for: media, ornamented: true)
                        }
                    }
                } header: {
                    Text(allMediaSectionHeaderText)
                        .font(.title2.weight(.semibold))
                }
            }
            .padding()
        }
    }
}
