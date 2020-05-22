//
//  ContentView.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import SwiftUI

// Ugly hack
private var gameIdString = ""

struct CreateGameScreen: View {

    @EnvironmentObject private var appState: AppState
    @State private var gameId: Game.ID?
    @State private var mode: GameMode = .join
    
}

extension CreateGameScreen {
    var body: some View {
        
        let idStringProxy = Binding<String>(
            get: { self.gameId?.identifier ?? gameIdString },
            set: {
                self.gameId = Game.ID(identifier: $0)
                gameIdString = $0
        }
        )
        
        return VStack {
            
            Picker("", selection: self.$mode) {
                ForEach(GameMode.allCases, id: \.self) {
                    Text($0.name)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .aspectRatio(contentMode: .fit)
            
            VStack {
                Text("Game id")
                TextField("<GAME_ID>", text: idStringProxy)
            }
            
            Button("\(self.mode.name) Game") {
                self.proceedToGame()
            }.enabled(self.canProceedToGame)
            
        }
        .padding(400)
        .onAppear { idStringProxy.wrappedValue = String.randomHex() }
    }
    
    var canProceedToGame: Bool {
        gameId != nil
    }
    
    func proceedToGame() {
        guard let gameId = gameId else { fatalError("no game id") }
        appState.update().userDid.joinOrCreateGame(withId: gameId, iAmCzar: mode.iAmCzar)
    }
}

private enum GameMode: String, CaseIterable, Equatable {
    case join, create
}

private extension GameMode {
    var name: String { rawValue.uppercased() }
    var iAmCzar: Bool {
        self == .create
    }
}
