//
//  Card.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Foundation

final class CardModel: ObservableObject, Identifiable {
    let card: Card
    @Published var isUsed: Bool = false
    
    init(card: Card) {
        self.card = card
    }
}

struct Card: Equatable, Decodable {

    let cardType: CardType
    let id: UInt
    let text: String
    
    init(_ text: String, type: CardType, id: UInt) {
        self.text = text
        self.cardType = type
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

