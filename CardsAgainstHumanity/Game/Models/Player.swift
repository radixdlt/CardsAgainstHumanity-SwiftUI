//
//  Player.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Foundation

struct Player: Equatable, Decodable, Identifiable {

    let id: ID
    let isMe: Bool
    let isCzar: Bool
    
    init(id: ID, isMe: Bool = false, isCzar: Bool = false) {
        self.id = id
        self.isMe = isMe
        self.isCzar = isCzar
    }
}

extension Player {
    
    typealias ID = Identifier<Self>
    
    static func me(isCzar: Bool, id: Player.ID) -> Self {
        .init(id: id, isMe: true, isCzar: isCzar)
    }
}
