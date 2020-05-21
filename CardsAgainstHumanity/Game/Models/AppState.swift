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
    
}


extension AppState.Update {
    final class AppShould {
        private unowned let preferences: Preferences
        
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
        return Game.init(id: gameId, me: .me(isCzar: iAmCzar))
    }
}
