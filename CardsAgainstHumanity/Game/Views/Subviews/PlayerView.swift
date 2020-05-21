//
//  PlayerView.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import SwiftUI

struct PlayerView: View {
    let player: Player
}

extension PlayerView {
    var body: some View {
        HStack {
            Text("\(player.id.description)")
            Group {
                if player.isMe {
                    Text("(me)")
                } else {
                    EmptyView()
                }
            }
            
            Group {
                if player.isCzar {
                    Text("(Czar)")
                } else {
                    EmptyView()
                }
            }
        }
    }
}
