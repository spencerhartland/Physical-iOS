//
//  GenreManager.swift
//  Physical
//
//  Created by Spencer Hartland on 7/20/23.
//

import Foundation
import SwiftData
import MusicKit

private struct GenresResponse: Decodable {
    let data: [Genre]
}

@Observable
final class GenreManager {
    var genres: [Genre]
    
    init() {
        self.genres = []
    }
    
    func fetchGenres() {
        Task {
            do {
                let countryCode = try await MusicDataRequest.currentCountryCode
                let url = URL(string: "https://api.music.apple.com/v1/catalog/\(countryCode)/genres")!
                
                let request = MusicDataRequest(urlRequest: URLRequest(url: url))
                let response = try await request.response()
                
                let genresResponse = try JSONDecoder().decode(GenresResponse.self, from: response.data)
                await self.update(genresResponse.data)
            } catch {
                print("Error fetching genres: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    private func update(_ genres: [Genre]) {
        self.genres = genres
    }
}
