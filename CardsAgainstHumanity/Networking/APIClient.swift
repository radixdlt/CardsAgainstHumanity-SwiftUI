//
//  APIClient.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-22.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Foundation
import Combine

func + (url: URL, path: String) -> String {
    var url = url
    url.appendPathComponent(path)
    return url.absoluteString
}

final class APIClient {
    private let gameId: Game.ID
    private let playerId: Player.ID
    private let httpClient: HTTPClient
    init(
        gameId: Game.ID,
        playerId: Player.ID,
        httpClient: HTTPClient = DefaultHTTPClient.shared
    ) {
        self.gameId = gameId
        self.playerId = playerId
        self.httpClient = httpClient
    }
    
    deinit {
        print("💣 DEINIT APIClient")
    }
}
extension APIClient {
    
//    private func request(path: String) -> URLRequest {
//        try! URLRequest.request(SecretServer.url + path)
//    }
    
//    func createGame() -> AnyPublisher<Void, Never> {
//        httpClient.data(
//            request(path: "create/\(gameId)\(playerId)")
//                .with(method: .POST)
//        ).assertNoFailure()
//        .eraseMapToVoid()
//    }
    
    func createGame() -> AnyPublisher<Void, Never> {
        httpClient.postFireForget(path: "create/\(gameId)/\(playerId)")
    }
    
    func fetchPlayers() -> AnyPublisher<[Player], Never> {
        httpClient.getDecode(path: "players/\(gameId)")
    }
    
    func startGame() -> AnyPublisher<Void, Never> {
        httpClient.postFireForget(path: "start/\(gameId)/\(playerId)")
    }
    
    func fetchAnswerCards() -> AnyPublisher<[Card], Never> {
         httpClient.getDecode(path: "cards/\(gameId)/\(playerId)")
    }
    
}

// MARK: MOCK
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
