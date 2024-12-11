//
//  ContentView.swift
//  RookRadar3
//
//  Created by Paul Hubbard on 12/8/24.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var isMonitoring = false // Track monitoring state

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
                            toggleMonitoring()
                        }) {
                            Text(isMonitoring ? "Stop Monitoring" : "Start Monitoring")
                                .padding()
                                .background(isMonitoring ? Color.red : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
        }
        .padding()
    }
    private func toggleMonitoring() {
            if isMonitoring {
                locationManager.stopMonitoringBeacons() // Implement stop logic in LocationManager
            } else {
                locationManager.startMonitoringBeacons()
            }
            isMonitoring.toggle()
        }
}
