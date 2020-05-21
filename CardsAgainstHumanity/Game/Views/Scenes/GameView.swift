//
//  GameView.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import SwiftUI

// MARK: View
struct GameView: View {
    @EnvironmentObject private var appState: AppState
    
    @ObservedObject var viewModel: GameViewModel
}

extension GameView {
    var body: some View {
        GeometryReader { geometry in
        NavigationView {
                self.masterView
                    .frame(width: geometry.size.width * 0.2)
                
                self.detailView
                    .frame(width: geometry.size.width * 0.8)
            }
        }
        .onAppear {
            self.viewModel.fetchPlayers()
            self.viewModel.fetchCards()
        }
    }
}

private extension GameView {
    var masterView: some View {
        
        List(self.viewModel.players) {
            PlayerView(player: $0)
        }
    }
    
    var detailView: some View {
        VStack {
            HStack {
                Text("Game id: ")
                Text("\(self.viewModel.game.id.description)")
            }
            cardsView
        }
    }
    
    var cardsView: some View {
        List(self.viewModel.cards) {
            CardView(card: $0)
        }
    }
}

// MARK: ViewModel
final class GameViewModel: ObservableObject {
    @Published var game: Game
    
    init(game: Game) {
        self.game = game
    }
}

extension GameViewModel {
    
    var players: [Player] {
        game.allPlayers
    }
    
    var cards: [Card] {
        game.cards
    }
    
    func fetchPlayers() {
        print("Fetching other players")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [unowned self] in
            print("Got players")
            self.game.otherPlayers = self.mockPlayers()
        }
    }
    
    func fetchCards() {
        print("Fetching cards")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            print("Got cards")
            self.game.cards = self.mockCards()
        }
    }
}

private extension GameViewModel {
    func mockPlayers() -> [Player] {
        ["Alice123", "Bob1234", "Clara12"].compactMap { Player.ID(identifier: $0) }.map { Player(id: $0) }
    }
    
    func mockCards() -> [Card] {
        var id: UInt = 1
        func answer(_ text: String, isUsed: Bool = false) -> Card {
            .init(text, type: .answer, isUsed: isUsed, id: id++)
        }
        
        return [
            answer("Saving up my boogers for ten years and then building the world's largest booger."),
            answer("Republicans."),
            answer("Not believing in giraffes.", isUsed: true),
            answer("Getting stuck in the toilet."),
            answer("Big Italian women making the spicy sauce."),
            answer("Mormon feminists.")
        ]
    }
}

postfix func ++ <I>(int: inout I) -> I where I: FixedWidthInteger {
    let beforeUpdate = int
    int += 1
    return beforeUpdate
}
