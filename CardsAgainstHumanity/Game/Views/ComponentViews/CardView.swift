//
//  CardView.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import SwiftUI

struct CardView: View {
    @ObservedObject var cardModel: CardModel
    let selection: (CardModel) -> Void
}

extension CardView {
    var body: some View {
        VStack {
            HStack {
                Text("\(self.cardModel.card.text)")
                    .font(.callout)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            Spacer()
            HStack {
                Spacer()
                Text("\(self.cardModel.card.id)")
                    .font(.footnote)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(25)
        .foregroundColor(self.cardModel.card.isAnswer ? .black : .white)
        .background(self.cardModel.card.isAnswer ? (self.cardModel.isUsed ? Color.red : .white) : Color.black)
        .cornerRadius(15)
            
        .frame(width: 250, height: 360)
        .onTapGesture {
            self.selection(self.cardModel)
        }
    }
}
