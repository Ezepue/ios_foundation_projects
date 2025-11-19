//
//  MovieStore.swift
//  myTV
//
//  Created by Chukwuebuka Ezepue on 02/10/2025.
//

import SwiftUI
import Combine

// MARK: - Load State
enum LoadState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}

// MARK: - MovieStore
/// Main store for managing movie data and application state
class MovieStore: ObservableObject {
    // MARK: - Published Properties
    @Published var movies: [Movie] = []
    @Published var loadState: LoadState = .idle
    @Published var searchResults: [Movie] = []
    @Published var searchQuery: String = ""
    @Published var selectedGenre: String?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Computed Properties
    
    /// All featured movies
    var featuredMovies: [Movie] {
        movies.filter { $0.sectionName == "Featured" }
    }
    
    /// All top chart movies
    var topChartMovies: [Movie] {
        movies.filter { $0.sectionName == "Top Chart" }
    }
    
    /// All popular movies
    var popularMovies: [Movie] {
        movies.filter { $0.sectionName == "Popular" }
    }
    
    /// All upcoming movies
    var upcomingMovies: [Movie] {
        movies.filter { $0.sectionName == "Coming Soon" }
    }
    
    /// All trending movies
    var trendingMovies: [Movie] {
        movies.filter { $0.sectionName?.contains("Trending") == true }
    }
    
    /// Movies grouped by section
    var moviesBySection: [String: [Movie]] {
        Dictionary(grouping: movies) { movie in
            movie.sectionName ?? "Unknown"
        }
    }
    
    /// Filtered movies based on selected genre
    var filteredMovies: [Movie] {
        guard let selectedGenre = selectedGenre else {
            return movies
        }
        return movies.filterByGenre(selectedGenre)
    }
    
    /// Check if currently loading
    var isLoading: Bool {
        loadState.isLoading
    }
    
    /// Current error message if any
    var errorMessage: String? {
        loadState.errorMessage
    }
    
    // MARK: - Initialization
    init() {
        setupSearchDebounce()
    }
    
    // MARK: - Public Methods
    
    /// Fetch all movies from API
    func fetchMovies() {
        guard !isLoading else { return }
        
        loadState = .loading
        
        MovieService.shared.fetchAllMovies { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedMovies):
                    self?.movies = fetchedMovies
                    self?.loadState = .loaded
                    
                case .failure(let error):
                    self?.loadState = .error(error.localizedDescription)
                    print("Error fetching movies: \(error)")
                }
            }
        }
    }
    
    /// Async refresh method for SwiftUI refreshable
    @MainActor
    func refreshMovies() async {
        loadState = .loading
        
        await withCheckedContinuation { continuation in
            MovieService.shared.fetchAllMovies { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedMovies):
                        self?.movies = fetchedMovies
                        self?.loadState = .loaded
                        
                    case .failure(let error):
                        self?.loadState = .error(error.localizedDescription)
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    /// Fetch movies from specific endpoints
    func fetchMovies(from endpoints: [MovieEndpoint]) {
        loadState = .loading
        
        MovieService.shared.fetchMovies(from: endpoints) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedMovies):
                    self?.movies = fetchedMovies
                    self?.loadState = .loaded
                    
                case .failure(let error):
                    self?.loadState = .error(error.localizedDescription)
                }
            }
        }
    }
    
    /// Search movies with debouncing
    func searchMovies(query: String) {
        searchQuery = query
        
        // Cancel previous search task
        searchTask?.cancel()
        
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }
        
        // Create new search task with debounce
        searchTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second debounce
            
            guard !Task.isCancelled else { return }
            
            MovieService.shared.searchMovies(query: query) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self, self.searchQuery == query else { return }
                    
                    switch result {
                    case .success(let movies):
                        self.searchResults = movies
                        
                    case .failure(let error):
                        print("Search error: \(error)")
                        self.searchResults = []
                    }
                }
            }
        }
    }
    
    /// Clear search results
    func clearSearch() {
        searchQuery = ""
        searchResults = []
        searchTask?.cancel()
    }
    
    /// Get movies for a specific section
    func movies(for section: String) -> [Movie] {
        moviesBySection[section] ?? []
    }
    
    /// Get movies for a specific section enum
    func movies(for section: MovieSection) -> [Movie] {
        switch section {
        case .featured: return featuredMovies
        case .topCharts: return topChartMovies
        case .regular: return popularMovies
        }
    }
    
    /// Filter movies by genre
    func filterByGenre(_ genre: String?) {
        selectedGenre = genre
    }
    
    /// Clear all filters
    func clearFilters() {
        selectedGenre = nil
    }
    
    /// Retry loading after error
    func retry() {
        fetchMovies()
    }
    
    // MARK: - Private Methods
    
    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                
                if query.isEmpty {
                    self.searchResults = []
                } else {
                    self.searchMovies(query: query)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - MovieStore Extensions

extension MovieStore {
    /// Get movie by ID
    func movie(withID id: Int) -> Movie? {
        return movies.first { $0.id == id }
    }
    
    /// Add movie to favorites (implement persistence separately)
    func toggleFavorite(_ movie: Movie) {
        // TODO: Implement favorite persistence
        print("Toggle favorite for: \(movie.title)")
    }
    
    /// Get random featured movie
    var randomFeaturedMovie: Movie? {
        return featuredMovies.randomElement()
    }
    
    /// Get top rated movie
    var topRatedMovie: Movie? {
        return topChartMovies.first
    }
}

// MARK: - Preview Helper
extension MovieStore {
    static var preview: MovieStore {
        let store = MovieStore()
        store.movies = Movie.sampleMovies
        store.loadState = .loaded
        return store
    }
    
    static var loading: MovieStore {
        let store = MovieStore()
        store.loadState = .loading
        return store
    }
    
    static var error: MovieStore {
        let store = MovieStore()
        store.loadState = .error("Failed to load movies")
        return store
    }
}
