//
//  GenreManager.swift
//  myTV
//
//  Created by Chukwuebuka Ezepue on 02/10/2025.
//

import Foundation

// MARK: - GenreManager
/// Manages genre mapping and caching for the application
/// Fetches genres from TMDB API and provides lookup functionality
class GenreManager {
    static let shared = GenreManager()
    
    // Dynamic genre map fetched from API
    private var genreMap: [Int: String] = [:]
    
    // Fallback static genre map (in case API fetch fails)
    private let fallbackGenreMap: [Int: String] = [
        28: "Action",
        12: "Adventure",
        16: "Animation",
        35: "Comedy",
        80: "Crime",
        99: "Documentary",
        18: "Drama",
        10751: "Family",
        14: "Fantasy",
        36: "History",
        27: "Horror",
        10402: "Music",
        9648: "Mystery",
        10749: "Romance",
        878: "Sci-Fi",
        10770: "TV Movie",
        53: "Thriller",
        10752: "War",
        37: "Western"
    ]
    
    private var isLoaded = false
    private var loadingCallbacks: [(Bool) -> Void] = []
    
    private init() {
        // Initialize with fallback map
        genreMap = fallbackGenreMap
    }
    
    // MARK: - Public Methods
    
    /// Load genres from API (call this when app launches)
    func loadGenres(completion: ((Bool) -> Void)? = nil) {
        // If already loaded, call completion immediately
        guard !isLoaded else {
            completion?(true)
            return
        }
        
        // Store callback if provided
        if let completion = completion {
            loadingCallbacks.append(completion)
        }
        
        // If already loading, don't fetch again
        guard loadingCallbacks.count <= 1 else {
            return
        }
        
        MovieService.shared.fetchGenres { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let genres):
                // Update genre map with fetched data
                self.genreMap = Dictionary(uniqueKeysWithValues: genres.map { ($0.id, $0.name) })
                self.isLoaded = true
                print("Loaded \(genres.count) genres from API")
                
                // Notify all waiting callbacks
                self.loadingCallbacks.forEach { $0(true) }
                self.loadingCallbacks.removeAll()
                
            case .failure(let error):
                print("Failed to load genres: \(error.localizedDescription)")
                print("Using fallback genre map")
                
                // Keep fallback map and mark as loaded
                self.isLoaded = true
                
                // Notify callbacks (still successful because we have fallback)
                self.loadingCallbacks.forEach { $0(false) }
                self.loadingCallbacks.removeAll()
            }
        }
    }
    
    /// Get genre names for an array of genre IDs
    func getGenres(for ids: [Int]) -> [String] {
        return ids.compactMap { genreMap[$0] }
    }
    
    /// Get a single genre name for a genre ID
    func getGenre(for id: Int) -> String? {
        return genreMap[id]
    }
    
    /// Get all available genres
    func getAllGenres() -> [(id: Int, name: String)] {
        return genreMap.map { (id: $0.key, name: $0.value) }
            .sorted { $0.name < $1.name }
    }
    
    /// Get genre IDs for given genre names (useful for filtering)
    func getGenreIDs(for names: [String]) -> [Int] {
        let lowercaseNames = names.map { $0.lowercased() }
        return genreMap.compactMap { id, name in
            lowercaseNames.contains(name.lowercased()) ? id : nil
        }
    }
    
    /// Check if genres are loaded
    var areGenresLoaded: Bool {
        return isLoaded
    }
    
    /// Format genres as a comma-separated string
    func formatGenres(for ids: [Int], maxCount: Int = 3) -> String {
        let genres = getGenres(for: ids)
        let displayGenres = Array(genres.prefix(maxCount))
        
        if genres.count > maxCount {
            return displayGenres.joined(separator: ", ") + " +\(genres.count - maxCount)"
        } else {
            return displayGenres.joined(separator: ", ")
        }
    }
}

// MARK: - Movie Extension
extension Movie {
    /// Computed property: returns genre names from the genre IDs
    var genres: [String] {
        guard let genreIDs = genreIDs else { return [] }
        return GenreManager.shared.getGenres(for: genreIDs)
    }
    
    /// Get formatted genre string (e.g., "Action, Comedy, Drama")
    var genresFormatted: String {
        guard let genreIDs = genreIDs else { return "" }
        return GenreManager.shared.formatGenres(for: genreIDs)
    }
    
    /// Get first genre (useful for category badges)
    var primaryGenre: String? {
        guard let genreIDs = genreIDs, !genreIDs.isEmpty else { return nil }
        return GenreManager.shared.getGenre(for: genreIDs[0])
    }
}

// MARK: - Array Extension
extension Array where Element == Movie {
    /// Filter movies by genre
    func filterByGenre(_ genreName: String) -> [Movie] {
        return self.filter { movie in
            movie.genres.contains { $0.lowercased() == genreName.lowercased() }
        }
    }
    
    /// Filter movies by multiple genres (OR logic)
    func filterByGenres(_ genreNames: [String]) -> [Movie] {
        let lowercaseGenres = genreNames.map { $0.lowercased() }
        return self.filter { movie in
            movie.genres.contains { genre in
                lowercaseGenres.contains(genre.lowercased())
            }
        }
    }
    
    /// Group movies by their primary genre
    func groupedByGenre() -> [String: [Movie]] {
        var grouped: [String: [Movie]] = [:]
        
        for movie in self {
            if let primaryGenre = movie.primaryGenre {
                grouped[primaryGenre, default: []].append(movie)
            }
        }
        
        return grouped
    }
}
