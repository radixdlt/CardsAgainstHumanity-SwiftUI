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
                
                self.cardsView
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
    
    var cardsView: some View {
        CardsView(cards: self.$viewModel.game.cards)
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
            self.game.cards = self.mockCards().map(CardModel.init)
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
//            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
//            if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["person"] as? [Any] {
//                // do stuff
//            }
            let cards = try JSONDecoder().decode([Card].self, from: data)
            return .init(cards.filter({ $0.isAnswer }).prefix(50))
        } catch {
            fatalError("Failed to parse cards json, error: \(error)")
        }
    }

//    func mockCards() -> [Card] {
//        var id: UInt = 1
//        func answer(_ text: String, isUsed: Bool = false) -> Card {
//            .init(text, type: .answer, isUsed: isUsed, id: id++)
//        }
//
//        return [
//            answer("Saving up my boogers for ten years and then building the world's largest booger."),
//            answer("Republicans."),
//            answer("Not believing in giraffes.", isUsed: true),
//            answer("Getting stuck in the toilet."),
//            answer("Big Italian women making the spicy sauce."),
//            answer("Mormon feminists.")
//        ]
//    }
}


postfix func ++ <I>(int: inout I) -> I where I: FixedWidthInteger {
    let beforeUpdate = int
    int += 1
    return beforeUpdate
}
