//
//  HomeView.swift
//  myTV
//
//  Created by Chukwuebuka Ezepue on 02/10/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var movieStore: MovieStore
    @State private var showingSearch = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showingProfile = false
    @State private var refreshTrigger = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 0) {
                    headerSection
                    
                    if movieStore.isLoading && movieStore.movies.isEmpty {
                        loadingStateView
                    } else if let errorMessage = movieStore.errorMessage {
                        errorStateView(errorMessage)
                    } else {
                        movieSectionsView
                    }
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("scroll")).minY
                        )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    .black,
                    Color(red: 0.1, green: 0.05, blue: 0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarHidden(true)
        .refreshable {
            await movieStore.refreshMovies()
        }
        .onAppear {
            if movieStore.movies.isEmpty {
                movieStore.fetchMovies()
            }
        }
        .sheet(isPresented: $showingSearch) {
            SearchView()
                .environmentObject(movieStore)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 24) {
            navigationBar
            
            if let featuredMovie = movieStore.featuredMovies.first {
                ModernHeroView(movie: featuredMovie)
                    .padding(.top, 8)
            }
        }
    }
    
    private var navigationBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("myTV")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Discover amazing content")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                searchButton
                profileButton
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .background(
            .ultraThinMaterial.opacity(scrollOffset < -50 ? 0.9 : 0),
            in: RoundedRectangle(cornerRadius: 0)
        )
        .animation(.easeInOut(duration: 0.3), value: scrollOffset)
    }
    
    private var searchButton: some View {
        Button(action: {
            showingSearch = true
            HapticManager.impact(.light)
        }) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.15))
                .backdrop(10)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .hoverEffect(.lift)
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3), value: showingSearch)
    }
    
    private var profileButton: some View {
        Button(action: {
            showingProfile = true
            HapticManager.impact(.light)
        }) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.15))
                .backdrop(10)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .hoverEffect(.lift)
    }
    
    private var movieSectionsView: some View {
        LazyVStack(spacing: 40) {
            ForEach(MovieSection.allCases, id: \.rawValue) { section in
                let sectionMovies = movieStore.movies(for: section)
                if !sectionMovies.isEmpty {
                    ModernSectionView(
                        section: section,
                        movies: sectionMovies
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
            }
        }
        .padding(.top, 24)
        .animation(.easeInOut(duration: 0.6), value: refreshTrigger)
    }
    
    private var loadingStateView: some View {
        VStack(spacing: 32) {
            ForEach(0..<3, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 20) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.1))
                        .frame(height: 32, alignment: .leading)
                        .frame(maxWidth: 200)
                        .shimmerEffect()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 20) {
                            ForEach(0..<5, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.white.opacity(0.08))
                                    .frame(width: 150, height: 220)
                                    .shimmerEffect()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .padding(.top, 40)
    }
    
    private func errorStateView(_ message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.red.opacity(0.7))
            
            Text("Something went wrong")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Try Again") {
                movieStore.retry()
                HapticManager.impact(.medium)
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.blue)
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    func backdrop(_ radius: CGFloat) -> some View {
        self.background(.ultraThinMaterial.opacity(0.3))
    }
}
