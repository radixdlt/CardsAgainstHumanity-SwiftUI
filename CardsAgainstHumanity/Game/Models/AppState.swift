//
//  AppState.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Foundation
import Combine

final class AppState: ObservableObject {
    
    @Published private(set) var rootContent: RootContent = .joinOrCreateGame
    
//    lazy var apiClient: APIClient = {
//        guard let gameId = self.preferences.gameId else {
//            fatalError("No Game ID")
//        }
//        
//        guard let playerId = self.preferences.playerId else {
//            fatalError("No player ID")
//        }
//        
//        return APIClient(gameId: gameId, playerId: playerId)
//    }()
    
    private let _update: Update
    
      private let preferences: Preferences
    
    private var cancellables = Set<AnyCancellable>()
    
    init(preferences: Preferences) {
         self.preferences = preferences
        let triggerNavigationSubject = CurrentValueSubject<Void, Never>(())
        
        
        self._update = Update(
            preferences: preferences,
            triggerNavigation: { triggerNavigationSubject.send() }
        )
        
        triggerNavigationSubject.sink { [unowned self] _ in
            self.goToNextScreen()
        }.store(in: &cancellables)
        
    }
}


// MARK: - PRIVATE
private extension AppState {
    
    func goToNextScreen() {
        rootContent = nextContent
        objectWillChange.send()
    }
    
    var nextContent: RootContent {

        if preferences.gameId == nil {
            return .joinOrCreateGame
        }
        
        guard preferences.hasGameStarted else {
            return .waitingForGameToStart
        }
        return .playGame
    }
}

// MARK: - PUBLIC

// MARK: Update State
extension AppState {
    // Syntax sugar enforcing function calling notation `.update()` rather than `.update` to highlight mutating
    func update() -> Update { _update }
}


// MARK: AppState.Update
extension AppState {
    final class Update {
        
        let userDid: UserDid
        let appShould: AppShould
        
        init(
            preferences: Preferences,
            triggerNavigation: @escaping () -> Void
        ) {
            self.userDid = UserDid(
                preferences: preferences,
                triggerNavigation: triggerNavigation
            )
            
            self.appShould = AppShould(
                preferences: preferences
            )
        }
    }
}


// MARK: AppState.Update.UserDid
extension AppState.Update {
    final class UserDid {
        
        private unowned let preferences: Preferences
        private let triggerNavigation: () -> Void
        
        init(
            preferences: Preferences,
            triggerNavigation: @escaping () -> Void
        ) {
            self.preferences = preferences
            self.triggerNavigation = triggerNavigation
        }
    }
}

// MARK: User Did Update
extension AppState.Update.UserDid {
    
    func joinOrCreateGame(withId gameId: Game.ID, iAmCzar: Bool) {
        preferences.gameId = gameId
        preferences.iAmCzar = iAmCzar
        triggerNavigation()
    }
 
    func startGame() {
        preferences.hasGameStarted = true
        // Hmm... fetch cards as well?? or how
        triggerNavigation()
    }
}


extension AppState.Update {
    final class AppShould {
        private unowned let preferences: Preferences

        
        lazy var apiClient: APIClient = {
            guard let gameId = self.preferences.gameId else {
                fatalError("No Game ID")
            }

            guard let usedPlayerId = self.preferences.playerId else {
                fatalError("No playerID")
            }
            
            print("Creating API Client")
            return APIClient(gameId: gameId, playerId: usedPlayerId)
        }()
        
        init(
            preferences: Preferences
        ) {
            self.preferences = preferences
        }
    }
}

// MARK: - PUBLIC
extension AppState.Update.AppShould {
    
    func createGame() -> Game {
   
        guard let gameId = preferences.gameId else {
            fatalError("Should have have id")
        }
        guard let iAmCzar = preferences.iAmCzar else {
            fatalError("Should have know if I am czar")
        }
        guard let playerID = preferences.playerId else {
            fatalError("Should have playerId?")
        }
        return Game.init(id: gameId, me: .me(isCzar: iAmCzar, id: playerID))
    }
    
    func provideAPIClient() -> APIClient {
        apiClient
    }
}
