//
//  ContentView.swift
//  FirstSwiftUI
//
//  Created by 임경문 on 2022/09/23.
//

import SwiftUI

struct ContentView: View {
    var a = 0
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("kyungmun, world")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(Color.orange)
            Text("my first swift app")

        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
