//
//  GenreSelectionView.swift
//  Physical
//
//  Created by Spencer Hartland on 7/20/23.
//

import SwiftUI
import MusicKit

struct GenreSelectionView: View {
    private let navTitle = "Genre"
    private let genreSelectionHeaderText = "Select a genre"
    private let selectionIndicatorSymbol = "checkmark"
    
    private var genres = MusicGenres()
    
    @Binding var selectedGenre: String
    
    init(selection: Binding<String>) {
        self._selectedGenre = selection
    }
    
    var body: some View {
        List(genres.all) { genre in
            HStack {
                Button(genre.name) {
                    selectedGenre = genre.name
                }
                Spacer()
                if genre.name == selectedGenre {
                    Image(systemName: selectionIndicatorSymbol)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                }
            }
        }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            genres.fetch()
        }
    }
}
