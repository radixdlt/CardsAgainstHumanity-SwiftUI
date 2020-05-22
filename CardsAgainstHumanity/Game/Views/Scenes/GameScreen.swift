//
//  GameScreen.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import SwiftUI
import Combine

// MARK: View
struct GameScreen: View {
    @EnvironmentObject private var appState: AppState
    
    @ObservedObject var viewModel: GameViewModel
}

extension GameScreen {
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

private extension GameScreen {

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
    
    private let apiClient: APIClient
    private var cancellables = Set<AnyCancellable>()
    
    init(game: Game, apiClient: APIClient) {
        self.game = game
        self.apiClient = apiClient
    }
}

extension GameViewModel {
    
    var iAmCzar: Bool {
        game.me.isCzar
    }
    
    func submitCardOrElectWinner() {
        guard let selectedCardModel = game.answerCards.filter({ $0.isSelected }).first else {
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
        
        apiClient
            .fetchPlayers()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [unowned self] players in
                print("Got players")
                self.game.otherPlayers = players
            })
            .store(in: &cancellables)
    }
    
    func fetchCards() {
        print("Fetching cards")
        
        apiClient
            .fetchAnswerCards()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [unowned self] cards in
                print("Got cards")
                self.game.answerCards = cards.map(CardModel.init)
            })
            .store(in: &cancellables)
    }
}
