//
//  GameList.swift
//  WordGuesser
//
//  Created by dimss on 29/01/2026.
//

import SwiftUI
import SwiftData

/// The `View` for array of `WordGuesser` games.
///
/// Adds some sample games on first load.
struct GameList: View {
    // MARK: Data In
    /// The most common words in English.
    @Environment(\.words) private var words
    /// The SwiftData model context.
    @Environment(\.modelContext) private var modelContext
    
    // MARK: Data Shared by Me
    /// The selected game.
    ///
    /// User can play in selected game.
    @Binding var selection: WordGuesser?
    /// The list of all games in app.
    @Query private var games: [WordGuesser] = []

    // MARK: Data Owned by Me
    /// The value indicating whether length chooser should open for creating new game.
    @State private var showLengthChooser: Bool = false

    /// Creates `GameList` view from searched games.
    ///
    /// The game has searched if it has previous attempt or current guess
    /// which contains searched `substring`.
    init(filter: FilterOption = .all, attemptContains substring: String = "", selection: Binding<WordGuesser?>) {
        _selection = selection
        let substring = substring.uppercased()
        let isCompletedOnly = filter == .completed
        let predicate = #Predicate<WordGuesser> { game in
            (!isCompletedOnly || game.isOver) && (
                substring.isEmpty ||
                game._attempts.contains { $0._word.contains(substring) } ||
                game.guess._word.contains(substring)
            )
        }
        _games = Query(filter: predicate)
    }
    
    /// The filter option determines the games to show.
    enum FilterOption: CaseIterable {
        /// Show all games.
        case all
        /// Show completed games.
        case completed
        
        /// The title of option in the UI.
        var title: String {
            switch self {
            case .all: "All games"
            case .completed: "Completed"
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        List(selection: $selection) {
            ForEach(games.sorted()) { game in
                NavigationLink(value: game) {
                    GameSummary(game: game)
                }
            }
            .onDelete { offsets in
                for offset in offsets {
                    modelContext.delete(games[offset])
                }
            }
        }
        .onChange(of: games) {
            if let selection, !games.contains(selection) {
                self.selection = nil
            }
        }
        .listStyle(.plain)
        .toolbar {
            settingsButton
            newGameButton
            EditButton()
        }
        .onChange(of: words.count, initial: true) {
            if words.count > 0 {
                addSamples()
            }
        }
    }
    
    /// The button to create new `WordGuesser` game.
    var newGameButton: some View {
        Button("New game", systemImage: "plus") {
            withAnimation {
                showLengthChooser = true
            }
        }
        .sheet(isPresented: $showLengthChooser) {
            lengthChooser
        }
    }
    
    /// The sheet lets choose the length of codes in the new game.
    var lengthChooser: some View {
        VStack {
            Text("Select code length")
                .font(.title3)
            HStack {
                ForEach(3...6, id: \.self) { length in
                    Button {
                        let newGame = WordGuesser(codeLength: length)
                        modelContext.insert(newGame)
                        showLengthChooser = false
                    } label: {
                        Text(String(length))
                    }
                }
            }
        }
    }
    
    /// The button which opens `AppSettings`.
    var settingsButton: some View {
        NavigationLink {
            AppSettings()
        } label: {
            Button("Settings", systemImage: "gear") {
            }
        }
    }
    
    /// Adds sample games if there are no one.
    func addSamples() {
        let fetchDescriptor = FetchDescriptor<WordGuesser>()
        if let result = try? modelContext.fetchCount(fetchDescriptor) {
            print("result: \(result)")
            print(games)
        }
        if let result = try? modelContext.fetchCount(fetchDescriptor), result == 0 {
            print("add samples")
            for i in 3...5 {
                let newGame = WordGuesser(codeLength: i)
                newGame.attemptGuess(count: i - 2) {
                    words.random(length: i)
                }
                modelContext.insert(newGame)
            }
        }
    }
}

#Preview(traits: .swiftData) {
    @Previewable @State var selection: WordGuesser?
    NavigationStack {
        GameList(selection: $selection)
    }
}
