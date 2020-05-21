//
//  Player.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Foundation

struct Player: Equatable, Identifiable {
    typealias ID = Identifier<Self>
    let id: ID
    var isCzar: Bool = false
}
