//
//  ContentView.swift
//  RookRadar3
//
//  Created by Paul Hubbard on 12/8/24.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        VStack {
            Text("Beacon Events")
                .font(.headline)
                .padding()

            List(locationManager.beaconEvents, id: \.self) { event in
                Text(event)
            }
            .padding()

            Spacer()

            Button(action: {
                locationManager.startMonitoringBeacons()
            }) {
                Text("Start Monitoring Beacons")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}
