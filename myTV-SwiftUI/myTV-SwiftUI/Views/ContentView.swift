//
//  ContentView.swift
//  myTV
//
//  Created by Chukwuebuka Ezepue on 02/10/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var movieStore = MovieStore()
    
    var body: some View {
        NavigationStack {
            HomeView()
                .environmentObject(movieStore)
        }
        .preferredColorScheme(.dark)
        .tint(.white)
        .onAppear {
            GenreManager.shared.loadGenres()
        }
    }
}

#Preview {
    ContentView()
}
