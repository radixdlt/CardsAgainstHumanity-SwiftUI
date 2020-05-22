//
//  CardsView.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Foundation
import SwiftUI
import QGrid

struct CardsView: View {
    var cards: Binding<[CardModel]>
}

extension CardsView {
    
    var body: some View {
        QGrid(self.cards.wrappedValue) {
            self.selectCard($0)
        }
        
    }
}

private extension CardsView {

    func selectCard(_ cardModel: CardModel) {
        cards.wrappedValue.forEach { $0.isSelected = false }
        cardModel.isSelected = true
    }
}

// MARK: Grid
extension QGrid where Data.Element == CardModel, Content == CardView {
    
    init(
        _ cards: Data,
        numberOfColumnsInPortrait: Int = 3,
        numberOfColumnsInLandscape: Int = 3,
        onSelection: @escaping (CardModel) -> Void
    ) {
        self.init(
            cards,
            columns: numberOfColumnsInPortrait,
            columnsInLandscape: numberOfColumnsInLandscape,
            vSpacing: 10,
            hSpacing: 10,
            vPadding: 30,
            hPadding: 30,
            isScrollable: true,
            showScrollIndicators: true
        ) {
            CardView(cardModel: $0, selection: onSelection)
        }
    }
}
