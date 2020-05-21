//
//  Game.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Foundation

final class Game: ObservableObject {
    typealias ID = Identifier<Game>
    
    var ugly_stringHolder: String = ""
    
    @Published var id: ID?
    @Published var hasStarted: Bool = false
    @Published var players: [Player] = .init()
    
    init(id: ID = .random()) {
        self.id = id
    }
}
