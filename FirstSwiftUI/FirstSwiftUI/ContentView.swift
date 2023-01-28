//
//  ContentView.swift
//  FirstSwiftUI
//
//  Created by 임경문 on 2022/09/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            MapView()
                .frame(height:300)
                //.frame(width: 400)
            
            CircleImage()
                .offset(y: -130)
                .padding(.bottom, -130)
            
            VStack(alignment: .leading){
                Text("lims, family")
                    .font(.title)
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("kyungmun")
                        .font(.subheadline)
                    Text("sohyun")
                        .font(.subheadline)
                    Text("doyoon")
                        .font(.subheadline)
                    Text("yeadam")
                        .font(.subheadline)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
        }
        .padding()

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
