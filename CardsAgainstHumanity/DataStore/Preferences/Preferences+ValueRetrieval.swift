//
// MIT License
//
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import SwiftUI
import Combine

extension Preferences {
    
    var iAmCzar: Bool? {
//        get { isTrue(.iAmCzar) }
        get { loadValue(forKey: .iAmCzar) }
        set { save(value: newValue ?? false, forKey: .iAmCzar) }
    }

    var gameId: Game.ID? {
        get {
            guard let idString: String = loadValue(forKey: .gameId) else {
                return nil
            }
            return Game.ID(identifier: idString)
        }
        set {
            guard let gameId = newValue else {
                fatalError("Really nil gameId?")
            }
            save(value: gameId.identifier, forKey: .gameId)
        }
    }
    
//    var playerId: Player.ID? {
//        get {
//            guard let idString: String = loadValue(forKey: .playerId) else {
//                return nil
//            }
//            return Player.ID(identifier: idString)
//        }
//        set {
//            guard let playerId = newValue else {
//                fatalError("Really nil playerId?")
//            }
//            save(value: playerId.identifier, forKey: .playerId)
//        }
//    }
    
//    var hasAgreedToTermsOfUse: Bool {
//        get { isTrue(.hasAgreedToTermsOfUse) }
//        set { save(value: newValue, forKey: .hasAgreedToTermsOfUse) }
//    }
//
//    var highestKnownHDAccountIndex: HDSubAccountAtIndex.Index {
//        get {
//            loadValue(forKey: .highestKnownHDAccountIndex) ?? 0
//        }
//        set {
//            save(value: newValue, forKey: .highestKnownHDAccountIndex)
//        }
//    }

}
