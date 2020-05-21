//
//  Game.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Foundation

struct Game {
    
    let id: ID
    let me: Player
    
    var otherPlayers = [Player]()
    var answerCards = [CardModel]()
    var questionCard: Card?
}

extension Game {
    
    typealias ID = Identifier<Self>
    
    var allPlayers: [Player] {
        [me] + otherPlayers
    }
}
