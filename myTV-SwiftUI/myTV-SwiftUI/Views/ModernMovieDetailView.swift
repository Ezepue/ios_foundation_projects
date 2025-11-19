//
//  ModernMovieDetailView.swift
//  myTV
//
//  Created by Chukwuebuka Ezepue on 02/10/2025.
//

import SwiftUI
import WebKit

struct ModernMovieDetailView: View {
    let movie: Movie
    @Environment(\.dismiss) private var dismiss
    @State private var showingTrailer = false
    @State private var trailerKey: String?
    @State private var isLoadingTrailer = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerImage
                contentSection
            }
        }
        .background(.black)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.black.opacity(0.6))
                        .clipShape(Circle())
                }
            }
        }
        .sheet(isPresented: $showingTrailer) {
            if let trailerKey = trailerKey {
                TrailerView(videoKey: trailerKey)
            }
        }
        .onAppear {
            fetchTrailer()
        }
    }
    
    private var headerImage: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: movie.posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 400)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(.gray.opacity(0.2))
                    .frame(height: 400)
                    .shimmerEffect()
            }
            
            LinearGradient(
                colors: [.clear, .black.opacity(0.8), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            titleSection
            actionButtons
            overviewSection
            detailsSection
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .background(.black)
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(movie.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            HStack(spacing: 16) {
                if let rating = movie.voteAverage {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
                
                Text(movie.formattedDate)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.gray)
                
                if !movie.genresText.isEmpty {
                    Text(movie.genresText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                }
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                if trailerKey != nil {
                    showingTrailer = true
                    HapticManager.impact(.medium)
                } else if !isLoadingTrailer {
                    fetchTrailer()
                }
            }) {
                HStack(spacing: 8) {
                    if isLoadingTrailer {
                        ProgressView()
                            .tint(.black)
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: trailerKey != nil ? "play.fill" : "exclamationmark.triangle")
                            .font(.system(size: 16, weight: .bold))
                    }
                    
                    Text(isLoadingTrailer ? "Loading..." : (trailerKey != nil ? "Watch Trailer" : "Trailer Unavailable"))
                        .font(.system(size: 18, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(trailerKey != nil ? .black : .white)
                .padding(.vertical, 16)
                .background(trailerKey != nil ? .white : .white.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isLoadingTrailer)
            
            HStack(spacing: 12) {
                Button(action: {
                    HapticManager.impact(.light)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("My List")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .padding(.vertical, 14)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
                }
                
                Button(action: {
                    HapticManager.impact(.light)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .padding(.vertical, 14)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(movie.overview)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.white.opacity(0.9))
                .lineSpacing(4)
        }
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            VStack(alignment: .leading, spacing: 12) {
                DetailRow(title: "Release Date", value: movie.formattedDate)
                DetailRow(title: "Genres", value: movie.genresText.isEmpty ? "N/A" : movie.genresText)
                if let rating = movie.voteAverage {
                    DetailRow(title: "Rating", value: String(format: "%.1f/10", rating))
                }
            }
        }
    }
    
    private func fetchTrailer() {
        isLoadingTrailer = true
        MovieService.shared.fetchTrailer(for: movie.id) { result in
            DispatchQueue.main.async {
                isLoadingTrailer = false
                switch result {
                case .success(let key):
                    trailerKey = key
                case .failure(let error):
                    print("Failed to fetch trailer: \(error)")
                    trailerKey = nil
                }
            }
        }
    }
}

struct TrailerView: View {
    let videoKey: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            YouTubeView(videoKey: videoKey)
                .navigationTitle("Trailer")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundStyle(.white)
                    }
                }
        }
        .preferredColorScheme(.dark)
    }
}

struct YouTubeView: UIViewRepresentable {
    let videoKey: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .black
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let youtubeURL = "https://www.youtube.com/embed/\(videoKey)?autoplay=1&playsinline=1"
        if let url = URL(string: youtubeURL) {
            uiView.load(URLRequest(url: url))
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.gray)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.white)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        ModernMovieDetailView(movie: Movie(
            id: 1,
            title: "Sample Movie",
            overview: "This is a great movie with an amazing storyline that will keep you engaged throughout.",
            posterPath: "/sample.jpg",
            releaseDate: "2024-01-15",
            voteAverage: 8.5,
            genreIDs: [28, 35]
        ))
    }
}
