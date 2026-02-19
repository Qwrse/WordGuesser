//
//  GameChooser.swift
//  WordGuesser
//
//  Created by dimss on 28/01/2026.
//

import SwiftUI

/// A `View` which draws `List` of games `WordGuesser`.
///
/// Holds all games as `@State` in memory.
struct GameChooser: View {
    // MARK: Data Owned by Me
    /// All games in app.
    @State private var selection: WordGuesser?
    /// The search input from user.
    @State private var search: String = ""
    @State private var filterOption = GameList.FilterOption.all

    // MARK: - Body
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            Picker("Filter", selection: $filterOption) {
                ForEach(GameList.FilterOption.allCases, id: \.self) { option in
                    Text(option.title)
                }
            }
            .pickerStyle(.segmented)
            GameList(filter: filterOption, attemptContains: search, selection: $selection)
                .animation(.default, value: filterOption)
                .navigationTitle("Word Guesser")
                .searchable(text: $search)
        } detail: {
            if let selection {
                WordGuesserView(game: selection)
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
