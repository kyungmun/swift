//
//  MapView.swift
//  FirstSwiftUI
//
//  Created by 임경문 on 2023/01/28.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
          center: CLLocationCoordinate2D(latitude: 37.200000, longitude: 127.150000),
          span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
      )
    
    var body: some View {
        Map(coordinateRegion: $region)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
