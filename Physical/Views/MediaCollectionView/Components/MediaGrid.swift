//
//  MediaGrid.swift
//  Physical
//
//  Created by Spencer Hartland on 7/18/23.
//

import SwiftUI
import SwiftData

struct MediaGrid: View {
    private let collection: [OrganizerSection]
    private let thumbnailsOrnamented: Bool
    
    init(_ collection: [OrganizerSection], thumbnailsOrnamented: Bool) {
        self.collection = collection
        self.thumbnailsOrnamented = thumbnailsOrnamented
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 128))], alignment: .leading, spacing: 16) {
                ForEach(collection) { section in
                    if !section.content.isEmpty {
                        Section {
                            ForEach(section.content) { media in
                                NavigationLink {
                                    MediaDetailView(media: media)
                                } label: {
                                    MediaThumbnail(for: media, ornamented: thumbnailsOrnamented)
                                }
                            }
                        } header: {
                            Text(section.title)
                                .font(.title2.weight(.semibold))
                        }
                    }
                }
            }
            .padding()
        }
    }
}
