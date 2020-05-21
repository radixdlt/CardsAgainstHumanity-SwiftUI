//
//  ContentView.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import SwiftUI

struct CreateGameView: View {
    
    @ObservedObject var game = Game()

    var body: some View {
        
        let idStringProxy = Binding<String>(
            get: { self.game.id?.identifier ?? self.game.ugly_stringHolder },
            set: {
                self.game.id = Game.ID(identifier: $0)
                self.game.ugly_stringHolder = $0
            }
        )
        
        return NavigationView {
            Group {
                if self.game.hasStarted {
                    List(self.game.players) { player in
                        Text("\(player.id.description)")
                    }.frame(idealWidth: 200, maxWidth: 300)
                } else {
                    VStack {
                        Spacer()
                        Text("Game id")
                        TextField("<GAME_ID>", text: idStringProxy)
                        NavigationLink("Start", destination: GameView().environmentObject(game)).disabled(self.game.id == nil)
                        Spacer()
                    }
                }
            }
        }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


//struct CreateGameView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateGameView()
//    }
//}
