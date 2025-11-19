//
//  MovieService.swift
//  myTV
//
//  Created by Chukwuebuka Ezepue on 02/10/2025.
//

import Foundation

// MARK: - Custom Errors
enum MovieServiceError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noData:
            return "No data received from server"
        }
    }
}

// MARK: - Movie Endpoints
enum MovieEndpoint {
    case popular
    case topRated
    case nowPlaying
    case upcoming
    case trending(timeWindow: TrendingTimeWindow)
    case discover
    case search(query: String)
    case details(id: Int)
    case similar(id: Int)
    case recommendations(id: Int)
    
    var path: String {
        switch self {
        case .popular:
            return "/movie/popular"
        case .topRated:
            return "/movie/top_rated"
        case .nowPlaying:
            return "/movie/now_playing"
        case .upcoming:
            return "/movie/upcoming"
        case .trending(let timeWindow):
            return "/trending/movie/\(timeWindow.rawValue)"
        case .discover:
            return "/discover/movie"
        case .search:
            return "/search/movie"
        case .details(let id):
            return "/movie/\(id)"
        case .similar(let id):
            return "/movie/\(id)/similar"
        case .recommendations(let id):
            return "/movie/\(id)/recommendations"
        }
    }
    
    var sectionName: String {
        switch self {
        case .popular:
            return "Popular"
        case .topRated:
            return "Top Chart"
        case .nowPlaying:
            return "Featured"
        case .upcoming:
            return "Coming Soon"
        case .trending(let timeWindow):
            return timeWindow == .day ? "Trending Today" : "Trending This Week"
        case .discover:
            return "Discover"
        case .search:
            return "Search Results"
        case .details, .similar, .recommendations:
            return ""
        }
    }
}

enum TrendingTimeWindow: String {
    case day, week
}

// MARK: - MovieService
class MovieService {
    static let shared = MovieService()
    
    private let apiKey = "b1a3142e007af3cdca542de5201e9b4d"
    private let baseURL = "https://api.themoviedb.org/3"
    
    private var genreCache: [Int: String] = [:]
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Public Methods
    
    /// Fetch movies from multiple endpoints
    func fetchAllMovies(completion: @escaping (Result<[Movie], MovieServiceError>) -> Void) {
        let endpoints: [MovieEndpoint] = [
            .popular,
            .topRated,
            .nowPlaying,
            .upcoming,
            .trending(timeWindow: .week)
        ]
        
        fetchGenres { [weak self] _ in
            self?.fetchMovies(from: endpoints, completion: completion)
        }
    }
    
    /// Fetch movies from specific endpoints
    func fetchMovies(from endpoints: [MovieEndpoint], completion: @escaping (Result<[Movie], MovieServiceError>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var allMovies: [Movie] = []
        var errors: [MovieServiceError] = []
        
        for endpoint in endpoints {
            dispatchGroup.enter()
            fetchMovies(from: endpoint) { result in
                switch result {
                case .success(var movies):
                    for i in 0..<movies.count {
                        movies[i].sectionName = endpoint.sectionName
                    }
                    allMovies += movies
                case .failure(let error):
                    errors.append(error)
                    print("⚠️ Error fetching \(endpoint.sectionName): \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if allMovies.isEmpty && !errors.isEmpty {
                completion(.failure(errors.first!))
            } else {
                completion(.success(allMovies))
            }
        }
    }
    
    /// Fetch movies from a single endpoint
    func fetchMovies(from endpoint: MovieEndpoint, page: Int = 1, completion: @escaping (Result<[Movie], MovieServiceError>) -> Void) {
        var urlString = "\(baseURL)\(endpoint.path)?api_key=\(apiKey)&language=en-US&page=\(page)"
        
        // Add query parameter for search
        if case .search(let query) = endpoint {
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            urlString += "&query=\(encodedQuery)"
        }
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            do {
                let movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(movieResponse.results))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(error)))
                }
            }
        }.resume()
    }
    
    /// Search movies by query
    func searchMovies(query: String, page: Int = 1, completion: @escaping (Result<[Movie], MovieServiceError>) -> Void) {
        fetchMovies(from: .search(query: query), page: page, completion: completion)
    }
    
    /// Fetch trailer for a specific movie
    func fetchTrailer(for movieID: Int, completion: @escaping (Result<String, MovieServiceError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/movie/\(movieID)/videos?api_key=\(apiKey)&language=en-US") else {
            completion(.failure(.invalidURL))
            return
        }
        
        session.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            do {
                let videoResponse = try JSONDecoder().decode(VideoResponse.self, from: data)
                let trailer = videoResponse.results.first { video in
                    video.type == "Trailer" && video.site == "YouTube"
                }
                
                DispatchQueue.main.async {
                    if let trailerKey = trailer?.key {
                        completion(.success(trailerKey))
                    } else {
                        completion(.failure(.noData))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(error)))
                }
            }
        }.resume()
    }
    
    /// Fetch genres and cache them
    func fetchGenres(completion: @escaping (Result<[Genre], MovieServiceError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/genre/movie/list?api_key=\(apiKey)&language=en-US") else {
            completion(.failure(.invalidURL))
            return
        }
        
        session.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            do {
                let genreResponse = try JSONDecoder().decode(GenreResponse.self, from: data)
                self?.genreCache = Dictionary(uniqueKeysWithValues: genreResponse.genres.map { ($0.id, $0.name) })
                DispatchQueue.main.async {
                    completion(.success(genreResponse.genres))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(error)))
                }
            }
        }.resume()
    }
    
    /// Get genre name from ID
    func getGenreName(for id: Int) -> String? {
        return genreCache[id]
    }
}

// MARK: - Response Models
struct MovieResponse: Decodable {
    let results: [Movie]
    let page: Int?
    let totalPages: Int?
    let totalResults: Int?
    
    enum CodingKeys: String, CodingKey {
        case results, page
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct GenreResponse: Decodable {
    let genres: [Genre]
}

struct Genre: Decodable, Identifiable {
    let id: Int
    let name: String
}

// MARK: - Video Response Models
struct VideoResponse: Decodable {
    let results: [Video]
}

struct Video: Decodable {
    let key: String
    let name: String
    let site: String
    let type: String
}
