//
//  Optional_Extensions.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Foundation

extension Optional {
    func get(orKill errorMessage: String) -> Wrapped {
        guard let value = self else {
            fatalError(errorMessage)
        }
        return value
    }
}
