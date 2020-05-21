//
//  Game.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Foundation

struct Game {
    typealias ID = Identifier<Self>
    
    let id: ID
    let me: Player
    var otherPlayers: [Player] = .init()
    var cards: [CardModel] = .init()
}

extension Game {
    var allPlayers: [Player] {
        [me] + otherPlayers
    }
}
