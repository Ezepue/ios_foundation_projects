//
//  SearchView.swift.swift
//  myTV-SwiftUI
//
//  Created by Chukwuebuka Ezepue on 02/10/2025.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var movieStore: MovieStore
    @State private var searchText = ""
    @State private var searchResults: [Movie] = []
    @State private var isSearching = false
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchHeader
                
                if isSearching {
                    searchLoadingView
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    emptySearchView
                } else if searchResults.isEmpty {
                    recentSearchesView
                } else {
                    searchResultsView
                }
            }
            .background(.black)
            .navigationBarHidden(true)
        }
        .onAppear {
            isSearchFieldFocused = true
        }
        .onChange(of: searchText) { newValue in
            searchMovies(query: newValue)
        }
    }
    
    private var searchHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(.white.opacity(0.15))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text("Search")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Color.clear
                    .frame(width: 36, height: 36)
            }
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.6))
                
                TextField("Search movies...", text: $searchText)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.white)
                    .focused($isSearchFieldFocused)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private var searchLoadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .tint(.white)
            Text("Searching...")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptySearchView: some View {
        VStack(spacing: 16) {
            Image(systemName: "film")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.3))
            
            Text("No results found")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
            
            Text("Try searching for a different movie")
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Popular Movies")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 20) {
                ForEach(movieStore.popularMovies.prefix(10), id: \.id) { movie in
                    NavigationLink(destination: ModernMovieDetailView(movie: movie)) {
                        SearchMovieCard(movie: movie)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private var searchResultsView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 20) {
                ForEach(searchResults, id: \.id) { movie in
                    NavigationLink(destination: ModernMovieDetailView(movie: movie)) {
                        SearchMovieCard(movie: movie)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
    
    private func searchMovies(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        // Use the actual API service for search
        MovieService.shared.searchMovies(query: query) { result in
            DispatchQueue.main.async {
                isSearching = false
                switch result {
                case .success(let movies):
                    searchResults = movies
                case .failure(let error):
                    print("Search error: \(error)")
                    searchResults = []
                }
            }
        }
    }
}

struct SearchMovieCard: View {
    let movie: Movie
    
    var body: some View {
        VStack(spacing: 12) {
            AsyncImage(url: movie.posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 240)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.1))
                    .frame(height: 240)
                    .shimmerEffect()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if let rating = movie.voteAverage {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
            .environmentObject(MovieStore.preview)
    }
}
