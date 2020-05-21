//
//  Card.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Foundation

struct Card: Equatable, Decodable, Identifiable {

    let cardType: CardType
    let id: UInt
    let text: String
    var isUsed: Bool
    
    init(_ text: String, type: CardType, isUsed: Bool = false, id: UInt) {
        self.text = text
        self.cardType = type
        self.isUsed = isUsed
        self.id = id
    }
    
    
}

extension Card {
    enum CardType: String, Equatable, Decodable {
        case answer, question
    }
    
    var isAnswer: Bool {
        cardType.isAnswer
    }
}

extension Card.CardType {
    var isAnswer: Bool {
        self == .answer
    }
}

