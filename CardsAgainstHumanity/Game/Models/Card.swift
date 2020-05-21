//
//  Card.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Foundation

struct Card: Equatable, Decodable {

    let cardType: CardType
    let id: UInt
    let text: String
    
}

extension Card {
    enum CardType: String, Equatable, Decodable {
        case answer, question
    }
}
