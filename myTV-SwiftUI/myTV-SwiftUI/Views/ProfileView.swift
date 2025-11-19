//
//  ProfileView.swift
//  myTV-SwiftUI
//
//  Created by Chukwuebuka Ezepue on 02/10/2025.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    profileHeader
                    profileStats
                    profileOptions
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
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
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .overlay(
                    Text("CU")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                )

            VStack(spacing: 4) {
                Text("Movie Enthusiast")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)

                Text("Discovering great content since 2024")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }

    private var profileStats: some View {
        HStack(spacing: 24) {
            StatItem(title: "Watched", value: "142")
            StatItem(title: "Favorites", value: "28")
            StatItem(title: "Watchlist", value: "15")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var profileOptions: some View {
        VStack(spacing: 16) {
            ProfileOptionRow(icon: "heart.fill", title: "My Favorites", color: .red)
            ProfileOptionRow(icon: "bookmark.fill", title: "Watchlist", color: .blue)
            ProfileOptionRow(icon: "clock.fill", title: "Watch History", color: .green)
            ProfileOptionRow(icon: "gear", title: "Settings", color: .gray)
            ProfileOptionRow(icon: "questionmark.circle", title: "Help & Support", color: .orange)
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ProfileView()
}
