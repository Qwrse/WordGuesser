//
//  GameChooser.swift
//  WordGuesser
//
//  Created by dimss on 28/01/2026.
//

import SwiftUI

/// A view that lets the player choose and open a game.
struct GameChooser: View {
    // MARK: Data Owned by Me
    /// The selected game.
    @State private var selectedGame: WordGuesser?
    /// The current search text.
    @State private var searchText = ""
    /// The active list filter.
    @State private var filter = GameList.FilterOption.all

    // MARK: - Body
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            Picker("Filter", selection: $filter) {
                ForEach(GameList.FilterOption.allCases, id: \.self) { option in
                    Text(option.title)
                }
            }
            .pickerStyle(.segmented)
            GameList(filter: filter, attemptContaining: searchText, selection: $selectedGame)
                .animation(.default, value: filter)
                .navigationTitle("Word Guesser")
                .searchable(text: $searchText)
        } detail: {
            if let selectedGame {
                WordGuesserView(game: selectedGame)
                    .navigationTitle("Guess master code!")
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                Text("Select a game")
            }
        }
    }
}

#Preview(traits: .swiftData) {
    GameChooser()
}
