//
//  GameView.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var game: Game
    
    var body: some View {
        VStack {
            HStack {
                Text("Game id: ")
                Text("\(self.game.id!.description)")
            }
        }.onAppear {
            print("Game has started")
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                print("Setting players")
                self.game.players = ["Alice123", "Bob1234", "Clara12"].compactMap { Player.ID(identifier: $0) }.map { Player(id: $0) }
            }
            self.game.hasStarted = true
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
