//
//  WaitingForGameToStartScreen.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-22.
//  Copyright © 2020 Cyon. All rights reserved.
//

import SwiftUI
import Combine

struct WaitingForGameToStartScreen: View {
    @ObservedObject var viewModel: WaitingForGameToStartViewModel
}

extension WaitingForGameToStartScreen {
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                
                Text("Waiting for game to start")
                    .font(.largeTitle)
                
                
                Text("#\(self.viewModel.playerCountExcludingMe) other players in game")
                    .font(.subheadline)

                
                if viewModel.iAmCzar {
                    Button("Start game") {
                        self.viewModel.startGame()
                    }.enabled(self.viewModel.canStartGame)
                }
                
                Spacer()
            }
            Spacer()
        }
        .onAppear {
            self.viewModel.fetchPlayers()
            if !self.viewModel.iAmCzar {
                self.viewModel.pollToCheckIfGameHasStarted()
            }
        }
    }
}

final class WaitingForGameToStartViewModel: ObservableObject {

    fileprivate let iAmCzar: Bool
    private unowned let apiClient: APIClient
    
    @Published var canStartGame = false
    
    @Published var playerCountExcludingMe = 0 {
        didSet {
            canStartGame = playerCountExcludingMe >= 2
        }
    }
    
    fileprivate var cancellables = Set<AnyCancellable>()
    
    private unowned let appState: AppState
    
    init(
        iAmCzar: Bool,
        apiClient: APIClient,
        appState: AppState
    ) {
        self.iAmCzar = iAmCzar
        self.apiClient = apiClient
        self.appState = appState
    }
}

extension WaitingForGameToStartViewModel {
    func startGame() {
        precondition(iAmCzar)
        apiClient
            .startGame()
            .receive(on: RunLoop.main)
        .sink(receiveValue: {
            print("start game received value")
            self.appState.update().userDid.startGame()
        })
            .store(in: &cancellables)
    }
    
    func pollToCheckIfGameHasStarted() {
        precondition(!iAmCzar)
        Timer.publish(every: 3, on: .main, in: .common)
            .autoconnect()
            .flatMap { [unowned self]_ in
                self.apiClient.fetchAnswerCards()
            }
            .filter({ cards in
                cards.isEmpty == false
            })
            .first()
            .eraseMapToVoid()
            .sink(receiveValue: {
                print("GAME HAS STARTED from a non-Czar player perspective")
                 self.appState.update().userDid.startGame()
            })
            .store(in: &cancellables)
    }
    
    func fetchPlayers() {
        print("Fetching other players from waiting for game to start view model")
        
        apiClient
            .fetchPlayers()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [unowned self] players in
                self.playerCountExcludingMe = players.count - 1
            })
            .store(in: &cancellables)
    }
}
