//
//  Movie.swift
//  myTV
//
//  Created by Chukwuebuka Ezepue on 02/10/2025.
//

import Foundation

// Represents a single movie returned from the API
struct Movie: Decodable {
    let id: Int                       // Unique ID of the movie
    let title: String                 // Movie title
    let overview: String              // Movie description/summary
    let posterPath: String?           // Path to the movie poster image
    let releaseDate: String?          // Release date in string format
    let voteAverage: Double?          // Average user rating
    let genreIDs: [Int]?              // Genre IDs associated with the movie

    // Used to categorize movies into sections (e.g. "Top Chart", "Now Playing")
    var sectionName: String?

    // Computed property to convert the poster path into a full image URL
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        // Constructs the full URL using TMDB's image base URL
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    // Returns genre names as a comma-separated string (e.g. "Action, Comedy")
    var genresText: String {
        // Uses a singleton manager to convert genre IDs to names
        GenreManager.shared.getGenres(for: genreIDs ?? []).joined(separator: ", ")
    }

    // Converts release date string into a more readable format (e.g. "Jan 1, 2025")
    var formattedDate: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"  // Expected format from API

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium       // Converts to something like "Jan 1, 2025"

        if let releaseDate = releaseDate,
           let date = inputFormatter.date(from: releaseDate) {
            return outputFormatter.string(from: date)
        }
        // Fallback if the date is missing or invalid
        return releaseDate ?? "Unknown"
    }

    // Custom keys to match the JSON field names from the API
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case genreIDs = "genre_ids"
    }

    // Custom initializer to decode from JSON and handle optional fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        overview = try container.decode(String.self, forKey: .overview)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage)
        genreIDs = try container.decodeIfPresent([Int].self, forKey: .genreIDs)
        sectionName = nil // This is set manually after decoding
    }
    
    // Manual initializer for SwiftUI previews and testing
    init(id: Int, title: String, overview: String, posterPath: String? = nil, releaseDate: String? = nil, voteAverage: Double? = nil, genreIDs: [Int]? = nil, sectionName: String? = nil) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.genreIDs = genreIDs
        self.sectionName = sectionName
    }
}

//// Struct to decode a list of movies from the API response
//struct MovieResponse: Decodable {
//    let results: [Movie]  // List of movies returned by the API
//}

// Enum representing sections in the home screen
enum MovieSection: Int, CaseIterable {
    case featured
    case topCharts
    case regular

    // Title to be displayed in the section header
    var title: String {
        switch self {
        case .featured: return "Featured"
        case .topCharts: return "Top Chart"
        case .regular: return "Popular"
        }
    }
}

extension Movie {
    static var sampleMovies: [Movie] {
        [
            Movie(id: 1, title: "Avengers: Endgame", overview: "The epic conclusion to the Infinity Saga", posterPath: "/sample1.jpg", releaseDate: "2019-04-26", voteAverage: 8.4, genreIDs: [28, 12], sectionName: "Featured"),
            Movie(id: 2, title: "Inception", overview: "A mind-bending thriller", posterPath: "/sample2.jpg", releaseDate: "2010-07-16", voteAverage: 8.8, genreIDs: [878, 53], sectionName: "Top Chart"),
            Movie(id: 3, title: "The Dark Knight", overview: "Batman faces the Joker", posterPath: "/sample3.jpg", releaseDate: "2008-07-18", voteAverage: 9.0, genreIDs: [28, 80], sectionName: "Popular")
        ]
    }
}
