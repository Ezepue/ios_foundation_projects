//
//  ModernMovieCard.swift
//  myTV
//
//  Created by Chukwuebuka Ezepue on 02/10/2025.
//

import SwiftUI

struct ModernMovieCard: View {
    let movie: Movie
    @State private var isPressed = false
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 0) {
            posterImage
            movieInfo
        }
        .frame(width: 160)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.95 : (isHovered ? 1.05 : 1.0))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onTapGesture {
            HapticManager.impact(.light)
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private var posterImage: some View {
        AsyncImage(url: movie.posterURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
        } placeholder: {
            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(height: 200)
                .shimmerEffect()
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 32))
                        .foregroundStyle(.white.opacity(0.3))
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var movieInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
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

            if !movie.genresText.isEmpty {
                Text(movie.genresText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
}

#Preview {
    ModernMovieCard(movie: Movie(
        id: 1,
        title: "Sample Movie Title",
        overview: "Great movie",
        voteAverage: 8.5
    ))
    .preferredColorScheme(.dark)
}
