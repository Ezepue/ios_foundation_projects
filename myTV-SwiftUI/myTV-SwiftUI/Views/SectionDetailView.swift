//
//  SectionDetailView.swift
//  myTV-SwiftUI
//
//  Created by Chukwuebuka Ezepue on 02/10/2025.
//

import SwiftUI

struct SectionDetailView: View {
    let section: MovieSection
    let movies: [Movie]
    @Environment(\.dismiss) private var dismiss
    @State private var sortOption: SortOption = .popularity
    
    enum SortOption: String, CaseIterable {
        case popularity = "Popularity"
        case rating = "Rating"
        case title = "Title"
        case year = "Year"
    }
    
    var sortedMovies: [Movie] {
        switch sortOption {
        case .popularity:
            return movies
        case .rating:
            return movies.sorted { ($0.voteAverage ?? 0) > ($1.voteAverage ?? 0) }
        case .title:
            return movies.sorted { $0.title < $1.title }
        case .year:
            return movies.sorted { ($0.releaseDate ?? "") > ($1.releaseDate ?? "") }
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 20) {
                ForEach(sortedMovies, id: \.id) { movie in
                    NavigationLink(destination: ModernMovieDetailView(movie: movie)) {
                        ModernMovieCard(movie: movie)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .background(.black)
        .navigationTitle(section.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(action: { sortOption = option }) {
                            HStack {
                                Text(option.rawValue)
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

