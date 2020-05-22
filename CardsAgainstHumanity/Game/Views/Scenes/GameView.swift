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
                self.playersView
                    .frame(width: geometry.size.width * 0.2, height: geometry.size.height)
                
                VStack {
                    self.questionCardView
                    Button(self.iAmCzar ? "Elect winner" : "Submit", action: self.viewModel.submitCardOrElectWinner)
                    self.answerCardsView
                }
                .frame(width: geometry.size.width * 0.8, height: geometry.size.height)
            }
        }
        .onAppear {
            self.viewModel.fetchPlayers()
            self.viewModel.fetchCards()
        }
    }
}

private extension GameView {

    var playersView: some View {
        VStack {
            HStack {
                Text("Game id: ")
                Text("\(self.viewModel.game.id.description)")
            }
            
            List(self.viewModel.game.allPlayers) {
                PlayerView(player: $0)
            }
        }
    }
    
    var questionCardView: some View {
        Group {
            if self.viewModel.game.questionCard != nil {
                Text("Question: \"\(self.viewModel.game.questionCard!.text)\"")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
            } else {
                Text("Waiting for next round")
                    .font(.largeTitle)
            }
        }
    }
    
    var answerCardsView: some View {
        CardsView(cards: self.$viewModel.game.answerCards)
    }
    
    var iAmCzar: Bool {
        viewModel.iAmCzar
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
    
    var iAmCzar: Bool {
        game.me.isCzar
    }
    
    func submitCardOrElectWinner() {
        guard let selectedCardModel = game.answerCards.filter { $0.isSelected }.first else {
            print("Cannot submit card or elect winner, no card selected")
            return
        }
        let selectedCard = selectedCardModel.card
        if iAmCzar {
            print("Electing winner, card: \(selectedCard)")
        } else {
            print("Submitting card...: \(selectedCard)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [unowned self] in
            self.game.answerCards.forEach({ $0.isSelected = false })
            if self.iAmCzar {
                print("Finished electing winner")
            } else {
                print("Finished Submitting card")
                selectedCardModel.isUsed = true
            }
        }
    }
    
    func fetchPlayers() {
        print("Fetching other players")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [unowned self] in
            print("Got players")
            self.game.otherPlayers = self.mockPlayers()
        }
    }
    
    func fetchCards() {
        print("Fetching cards")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            print("Got cards")
            self.game.answerCards = self.mockCards().map(CardModel.init)
        }
    }
}

private extension GameViewModel {
    func mockPlayers() -> [Player] {
        ["Alice123", "Bob1234", "Clara12"].compactMap { Player.ID(identifier: $0) }.map { Player(id: $0) }
    }
    
    func mockCards() -> [Card] {
        guard let path = Bundle.main.path(forResource: "cards", ofType: "json") else { fatalError("Failed to find cards.json file") }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let cards = try JSONDecoder().decode([Card].self, from: data)
            self.game.questionCard = cards.filter({ !$0.isAnswer }).randomElement()
            return .init(cards.filter({ $0.isAnswer }).prefix(15))
        } catch {
            fatalError("Failed to parse cards json, error: \(error)")
        }
    }
}


postfix func ++ <I>(int: inout I) -> I where I: FixedWidthInteger {
    let beforeUpdate = int
    int += 1
    return beforeUpdate
}
