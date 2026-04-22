//
//  GameList.swift
//  WordGuesser
//
//  Created by dimss on 29/01/2026.
//

import SwiftUI
import SwiftData

/// A view that presents the saved games.
struct GameList: View {
    // MARK: Data In
    /// The shared word store.
    @Environment(\.words) private var words
    /// The SwiftData model context.
    @Environment(\.modelContext) private var modelContext
    
    // MARK: Data Shared by Me
    /// The currently selected game.
    @Binding var selection: WordGuesser?
    /// The saved games that match the current filter.
    @Query private var games: [WordGuesser] = []

    // MARK: Data Owned by Me
    /// A Boolean value that indicates whether the length chooser is presented.
    @State private var isShowingLengthChooser = false

    /// Creates a game list filtered by completion state and text.
    init(filter: FilterOption = .all, attemptContaining searchText: String = "", selection: Binding<WordGuesser?>) {
        _selection = selection
        let searchText = searchText.uppercased()
        let isCompletedOnly = filter == .completed
        let predicate = #Predicate<WordGuesser> { game in
            (!isCompletedOnly || game.isOver) && (
                searchText.isEmpty ||
                game._attempts.contains { $0._word.contains(searchText) } ||
                game.guess._word.contains(searchText)
            )
        }
        _games = Query(filter: predicate)
    }
    
    /// A filter that determines which games appear in the list.
    enum FilterOption: CaseIterable {
        /// Shows every game.
        case all
        /// Shows only completed games.
        case completed
        
        /// The title shown in the picker.
        var title: String {
            switch self {
            case .all: "All games"
            case .completed: "Completed"
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        let sortedGames = games.sorted()
        List(selection: $selection) {
            ForEach(sortedGames) { game in
                NavigationLink(value: game) {
                    GameSummary(game: game)
                }
            }
            .onDelete { offsets in
                for offset in offsets {
                    modelContext.delete(sortedGames[offset])
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
                insertSampleGamesIfNeeded()
            }
        }
    }
    
    /// A button that presents the new-game length chooser.
    var newGameButton: some View {
        Button("New game", systemImage: "plus") {
            withAnimation {
                isShowingLengthChooser = true
            }
        }
        .sheet(isPresented: $isShowingLengthChooser) {
            lengthChooser
        }
    }
    
    /// A sheet that lets the player choose a code length.
    var lengthChooser: some View {
        VStack {
            Text("Select code length")
                .font(.title3)
            HStack {
                ForEach(3...6, id: \.self) { length in
                    Button {
                        let newGame = WordGuesser(codeLength: length)
                        modelContext.insert(newGame)
                        isShowingLengthChooser = false
                    } label: {
                        Text(String(length))
                    }
                }
            }
        }
    }
    
    /// A link that opens the app settings.
    var settingsButton: some View {
        NavigationLink {
            AppSettings()
        } label: {
            Button("Settings", systemImage: "gear") {
            }
        }
    }
    
    /// Inserts sample games when the store is empty.
    func insertSampleGamesIfNeeded() {
        let fetchDescriptor = FetchDescriptor<WordGuesser>()
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
