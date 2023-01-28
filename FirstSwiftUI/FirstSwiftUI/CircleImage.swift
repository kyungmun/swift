//
//  CircleImage.swift
//  FirstSwiftUI
//
//  Created by 임경문 on 2023/01/28.
//

import SwiftUI

struct CircleImage: View {
    var body: some View {
        Image("img-kids")
            .clipShape(Circle())
            .overlay{
                Circle().stroke(.gray, lineWidth: 1)
            }
            .shadow(radius: 7)
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleImage()
    }
}
