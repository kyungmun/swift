//
//  AnimationView.swift
//  codestats
//
//  Created by 임경문 on 2023/03/26.
//

import SwiftUI

struct AnimationView: View {
    @State var turnRed: Bool = false
    var body: some View {
        VStack{
//            Circle()
//                .foregroundColor(turnRed ? .gray : .red)
//                .animation(.easeOut(duration: 3), value: turnRed)
            Rectangle()
                .frame(width:20, height:100)
                .offset(x : turnRed ? 100 : -100)
                .animation(.easeIn(duration: 3), value: turnRed)
                .foregroundColor(.orange)
            Rectangle()
                .frame(width:20, height:100)
                .offset(x : turnRed ? 100 : -100)
                .animation(.easeOut(duration: 3), value: turnRed)
                .foregroundColor(.green)
            Rectangle()
                .frame(width:20, height:100)
                .offset(x : turnRed ? 100 : -100)
                .animation(.linear(duration: 3), value: turnRed)
                .foregroundColor(.blue)
            Rectangle()
                .frame(width:20, height:100)
                .offset(x : turnRed ? 100 : -100)
                .animation(.easeInOut(duration: 3), value: turnRed)
                .foregroundColor(.red)
            Button {
                turnRed.toggle()
            } label: {
                Text("색 변화")
            }
            
        }
        .padding()
    }
}

struct AnimationView_Previews: PreviewProvider {
    static var previews: some View {
        AnimationView()
    }
}
