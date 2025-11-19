//
//  ModernHeroView.swift
//  myTV
//
//  Created by Chukwuebuka Ezepue on 02/10/2025.
//

import SwiftUI

struct ModernHeroView: View {
    let movie: Movie
    
    var body: some View {
        ZStack {
            AsyncImage(url: movie.posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 500)
                    .clipped()
                    .overlay(alignment: .bottom) {
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.8), .black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
            } placeholder: {
                Rectangle()
                    .fill(.gray.opacity(0.2))
                    .frame(height: 500)
                    .shimmerEffect()
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                
                Text(movie.title)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(radius: 4)
                
                if !movie.genresText.isEmpty {
                    Text(movie.genresText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(radius: 2)
                }
                
                actionButtons
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 16)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            NavigationLink(destination: ModernMovieDetailView(movie: movie)) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text("Watch Now")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
            }
            .buttonStyle(.plain)
            
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                    Text("My List")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

extension View {
    func shimmerEffect() -> some View {
        self.overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.4), .clear],
                        startPoint: UnitPoint(x: -0.5, y: 0.5),
                        endPoint: UnitPoint(x: 1.5, y: 0.5)
                    )
                )
                .rotationEffect(.degrees(15))
                .animation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: false),
                    value: UUID()
                )
        )
        .clipped()
    }
}

#Preview {
    ModernHeroView(movie: Movie(
        id: 1,
        title: "Sample Movie",
        overview: "A great movie",
        posterPath: "/sample.jpg",
        genreIDs: [28, 35]
    ))
}
