//
//  APIClient.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-22.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Foundation
import Combine

final class APIClient {
    private let gameId: Game.ID
    private let playerId: Player.ID
    
    init(
        gameId: Game.ID,
        playerId: Player.ID
    ) {
        self.gameId = gameId
        self.playerId = playerId
    }
    
    deinit {
        print("💣 DEINIT APIClient")
    }
}
extension APIClient {
    func fetchPlayers() -> AnyPublisher<[Player], Never> {
        print("APIClient: fetching players")
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [unowned self] in
//            print("Got players")
//            self.game.otherPlayers = self.mockPlayers()
//        }
        
        return Just(mockPlayers())
            .delay(for: 1, scheduler: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    func startGame() -> AnyPublisher<Void, Never> {
        Just(())
            .delay(for: 1, scheduler: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    func fetchAnswerCards() -> AnyPublisher<[Card], Never> {
        //        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [unowned self] in
        //            print("Got players")
        //            self.game.otherPlayers = self.mockPlayers()
        //        }
        
        Just(MockPlayerMemoizer.shared.mockedCardsAnswers())
            .delay(for: 1, scheduler: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
}

private extension APIClient {
    func mockPlayers() -> [Player] {
        ["Alice123", "Bob1234", "Clara12"].compactMap { Player.ID(identifier: $0) }.map { Player(id: $0) }
    }
}

private final class MockPlayerMemoizer {
    static let shared = MockPlayerMemoizer()
    
    private let count = 30
    private lazy var mockedCards: [Card] = {
        guard let path = Bundle.main.path(forResource: "cards", ofType: "json") else { fatalError("Failed to find cards.json file") }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let allCards = try JSONDecoder().decode([Card].self, from: data)
            let answers = allCards.filter { $0.isAnswer }
            let questions = allCards.filter { !$0.isAnswer }
            return [Card](answers.prefix(count) + questions.prefix(count))
        } catch {
            fatalError("Failed to parse cards json, error: \(error)")
        }
    }()
    
    private var questions: [Card] {
        mockedCards.lazy.filter { !$0.isAnswer }
    }
    
    private var answers: [Card] {
        mockedCards.lazy.filter { $0.isAnswer }
    }
    
    func mockedCardsAnswers(count: Int = 20) -> [Card] {
        precondition(count <= self.count)
        return [Card](answers.prefix(count))
    }
    
    func mockedCardsQuestions(count: Int = 20) -> [Card] {
        precondition(count <= self.count)
        return [Card](questions.prefix(count))
    }
}
