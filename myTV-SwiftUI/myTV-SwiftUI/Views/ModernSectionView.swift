//
//  ModernSectionView.swift
//  myTV
//
//  Created by Chukwuebuka Ezepue on 02/10/2025.
//

import SwiftUI

struct ModernSectionView: View {
    let section: MovieSection
    let movies: [Movie]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            sectionHeader
            movieScrollView
        }
    }

    private var sectionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(section.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("\(movies.count) movies")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            NavigationLink(destination: SectionDetailView(section: section, movies: movies)) {
                HStack(spacing: 6) {
                    Text("See All")
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(.white.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.white.opacity(0.1))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
    }

    private var movieScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 20) {
                ForEach(movies.prefix(15), id: \.id) { movie in
                    NavigationLink(destination: ModernMovieDetailView(movie: movie)) {
                        ModernMovieCard(movie: movie)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    NavigationStack {
        ModernSectionView(
            section: .regular,
            movies: [
                Movie(id: 1, title: "Sample Movie 1", overview: "Great movie", voteAverage: 8.5),
                Movie(id: 2, title: "Sample Movie 2", overview: "Another great movie", voteAverage: 7.8)
            ]
        )
        .preferredColorScheme(.dark)
    }
}
