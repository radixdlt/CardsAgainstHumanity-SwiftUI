//
//  CardView.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import SwiftUI

struct CardView: View {
    var card: Card
}

extension CardView {
    var body: some View {
        VStack {
            
            HStack {
                
                Text("\(card.text)")
                    .font(.callout)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                    Spacer()
            Text("\(card.id)")
                .font(.footnote)
                .multilineTextAlignment(.trailing)
            }
                
        }
        .padding(25)
        .foregroundColor(card.isAnswer ? .black : .white)
        .background(card.isAnswer ? (card.isUsed ? Color.red : .white) : Color.black)
        .cornerRadius(15)
        .frame(width: 250, height: 360)
    }
}
