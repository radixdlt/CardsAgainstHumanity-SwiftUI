//
//  Identifier.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Foundation

struct Identifier<Entity>: Hashable, CustomStringConvertible, ExpressibleByStringLiteral, Decodable {
    let identifier: String
    init?(identifier: String) {
        guard identifier.count >= lengthIdentifierString else {
            return nil
        }
        self.identifier = .init(identifier.prefix(lengthIdentifierString))
    }
}

extension Identifier {
    
    init(stringLiteral value: String) {
        guard let selfId = Self.init(identifier: value) else {
            fatalError("bad literal: \(value)")
        }
        self = selfId
    }
    
    var description: String { identifier }
    
    static func random() -> Self {
        guard let id = Self(identifier: UUID().uuidString.replacingOccurrences(of: "-", with: "")) else {
            fatalError("should always be able to create random id")
        }
        return id
    }
}

let lengthIdentifierString = 7
extension String {
    static func randomHex(length: Int = lengthIdentifierString) -> Self {
        func makeRandom() -> String {
            .init(UUID().uuidString.replacingOccurrences(of: "-", with: ""))
        }
        var string = makeRandom()
        while string.count < length {
            string += makeRandom()
        }
        return .init(string.prefix(length))
    }
}
